pragma solidity ^0.4.18;

import 'minimetoken/contracts/TokenController.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/TokenVesting.sol';

import './Bounty0xToken.sol';
import './BntyExchangeRateCalculator.sol';
import './KnowsConstants.sol';
import './AddressWhitelist.sol';
import './Bounty0xPresaleDistributor.sol';

contract Bounty0xCrowdsale is KnowsConstants, BntyExchangeRateCalculator, AddressWhitelist, Pausable, TokenController {
    using SafeMath for uint;

    // Crowdsale contracts
    Bounty0xToken public bounty0xToken;                                 // Reward tokens to compensate in
    Bounty0xPresaleDistributor public presaleDistributor;               // contract that manages distributing presale awards

    // Special addresses
    address public founder1;                                            // Wallet of founder 1
    address public founder2;                                            // Wallet of founder 2
    address public founder3;                                            // Wallet of founder 3
    address public bounty0xWallet;                                      // Bounty0x Wallet
    address[] public advisers;                                          // 4 Wallets of advisers
    bool vestedTokensDistributed;

    // Contribution amounts
    mapping (address => uint) public contributionAmounts;            // The amount that each address has contributed
    uint public totalContributions;                                  // Total contributions given

    // Constants derived from the USD price of ether
    uint public maxPresaleContributionsWei;
    uint public maxPublicSaleContributionsWei;
    uint public hardCapWei;

    // Events
    event OnContribution(address indexed contributor, bool indexed duringPresale, uint indexed contributedWei, uint bntyAwarded);

    function Bounty0xCrowdsale(uint fixedUSDEtherPrice, address _founder1, address _founder2, address _founder3, address _bounty0xWallet, address[] _advisers)
        BntyExchangeRateCalculator(MICRO_DOLLARS_PER_BNTY_MAINSALE, fixedUSDEtherPrice)
        public
    {
        require(_advisers.length == 4);

        advisers = _advisers;
        founder1 = _founder1;
        founder2 = _founder2;
        founder3 = _founder3;
        bounty0xWallet = _bounty0xWallet;

        maxPresaleContributionsWei = usdToWei(MAXIMUM_CONTRIBUTION_AMOUNT_USD_DURING_WHITELIST);
        maxPublicSaleContributionsWei = usdToWei(MAXIMUM_CONTRIBUTION_AMOUNT_USD_POST_WHITELIST);
        hardCapWei = usdToWei(HARD_CAP_AMOUNT_USD);
    }


    // All contributions come through the fallback function
    function () payable public whenNotPaused {
        // require that they haven't sent too much gas
        require(tx.gasprice <= MAX_GAS_PRICE);

        // require the sale has started
        require(now >= SALE_START_DATE);

        // require that the sale has not ended
        require(now < SALE_END_DATE);

        bool isDuringPresale = now < WHITELIST_END_DATE;

        // if we are in the presale, we need to make sure the sender is on the whitelist
        if (isDuringPresale) {
            require(isWhitelisted(msg.sender));
            // also they must adhere to the maximum of $1.5k
            require(contributionAmounts[msg.sender].add(msg.value) < maxPresaleContributionsWei);
        } else {
            // otherwise they adhere to the public maximum of $10k
            require(contributionAmounts[msg.sender].add(msg.value) < maxPublicSaleContributionsWei);
        }

        // require we are not at the cap
        require(totalContributions.add(msg.value) < hardCapWei);

        // account contribution towards total
        totalContributions = totalContributions.add(msg.value);

        // account contribution towards address total
        contributionAmounts[msg.sender] = contributionAmounts[msg.sender].add(msg.value);

        // and send them some bnty
        uint amountBntyRewarded = weiToBnty(msg.value);
        bounty0xToken.transfer(msg.sender, amountBntyRewarded);

        // log the contribution
        OnContribution(msg.sender, isDuringPresale, msg.value, amountBntyRewarded);
    }

    //  @notice Sets Bounty0xToken contract
    //  Generates all BNTY tokens and assigns them to this contract
    //  If token contract has already generated tokens, do not generate again
    //  @param _Bounty0xToken Bounty0xToken address
    function setBounty0xToken(Bounty0xToken _bounty0xToken) public onlyOwner {
        bounty0xToken = _bounty0xToken;

        // the token must have 0 supply when it is transferred to this contract
        require(bounty0xToken.totalSupply() == 0);

        uint totalSupply = MAINSALE_POOL
            .add(PRESALE_POOL)
            .add(FOUNDER1_STAKE)
            .add(FOUNDER2_STAKE)
            .add(FOUNDER3_STAKE)
            .add(BOUNTY0X_RESERVE)
            .add(ADVISERS_POOL)
            .mul(10 ** 18);

        // generate all the tokens that will need to be distributed
        require(bounty0xToken.generateTokens(this, totalSupply));

        // check that this contract has control of the total supply
        assert(bounty0xToken.totalSupply() == bounty0xToken.balanceOf(this));

        // check that the total supply is 500M
        assert(bounty0xToken.totalSupply() == MAXIMUM_TOKEN_SUPPLY.mul(10 ** 18));
    }

    // Create the contract responsible for distributing presale bounties based on the presale contract
    function setBounty0xPresaleDistributor(Bounty0xPresaleDistributor _presaleDistributor) public onlyOwner returns (bool success) {
        require(presaleDistributor == address(0));
        require(_presaleDistributor != address(0));
        require(bounty0xToken != address(0));

        // assign the presaleDistributor contract address
        presaleDistributor = _presaleDistributor;

        // assert the presale distributor contract has no balance yet
        assert(bounty0xToken.balanceOf(presaleDistributor) == 0);

        // fund the presale distributor contract
        bounty0xToken.transfer(presaleDistributor, PRESALE_POOL.mul(10 ** 18));

        // assert the presale distributor contract has the presale pool in its balance
        assert(bounty0xToken.balanceOf(presaleDistributor) == PRESALE_POOL.mul(10 ** 18));

        return true;
    }

    // This function call creates all the the vesting contracts and gives them the appropriate amounts of BNTY
    function distributeVestedTokens() public onlyOwner returns (bool success) {
        require(!vestedTokensDistributed);

        // founder 1
        createFounderTokenVestingContract(founder1, FOUNDER1_STAKE);
        createFounderTokenVestingContract(founder2, FOUNDER2_STAKE);
        createFounderTokenVestingContract(founder3, FOUNDER3_STAKE);

        // adviser distribution amounts
        uint adviserDistributionAmount = ADVISERS_POOL.mul(10 ** 18).div(advisers.length);

        for (uint i = 0; i < advisers.length; i++) {
            TokenVesting vesting = new TokenVesting(advisers[i], SALE_START_DATE, ADVISERS_VESTING_CLIFF, ADVISERS_VESTING_PERIOD, false);
            bounty0xToken.transfer(vesting, adviserDistributionAmount);
        }

        vestedTokensDistributed = true;
        return true;
    }

    function createFounderTokenVestingContract(address founder, uint stake) private returns (address) {
        TokenVesting vesting = new TokenVesting(founder, SALE_START_DATE, TEAM_VESTING_CLIFF, TEAM_VESTING_PERIOD, false);
        bounty0xToken.transfer(founder, stake.mul(10 ** 18));
        return vesting;
    }

    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns (bool) {
        return false;
    }

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns (bool) {
        return canSend(_from);
    }

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {
        return canSend(_owner);
    }

    function canSend(address sender) private view returns (bool) {
        return sender == address(this) || sender == address(presaleDistributor);
    }

}