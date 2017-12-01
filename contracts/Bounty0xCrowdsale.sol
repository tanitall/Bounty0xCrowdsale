pragma solidity ^0.4.18;

import 'minimetoken/contracts/TokenController.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/TokenVesting.sol';

import './Bounty0xToken.sol';
import './Bounty0xPresaleDistributor.sol';

contract Bounty0xCrowdsale is Pausable, TokenController {
    using SafeMath for uint256;

    Bounty0xToken public bounty0xToken;                                 // Reward tokens to compensate in
    Bounty0xPresaleDistributor public presaleDistributor;               // contract that manages distributing presale awards

    address public multiSigWallet                                       // Multi-sig wallet to transfer contributions to
    address public founder1;                                            // Wallet of founder 1
    address public founder2;                                            // Wallet of founder 2
    address public founder3;                                            // Wallet of founder 3
    address public bounty0xWallet;                                      // Bounty0x Wallet
    address[] public advisers;                                          // 4 Wallets of advisers
    mapping (address => bool) public whitelistContributors;

    // Crowdsale Conditions
    mapping (address => uint256) public contributors;
    uint256 public maximumParticipationAmount = 3.16 ether;             // Maximum initial constribution cap per person
    uint256 public constant MINIMUM_PARTICIPATION_AMOUNT = 0.1 ether;   // IN ETH minimum one can contribute
    uint256 public constant MAXIMUM_TOKEN_SUPPLY = 500000000;           // maximum BNTY tokens to be minted at any given point
    uint256 public constant HARD_CAP_AMOUNT = 3260 ether;               // in ETH
    uint256 public constant MAINSALE_FIX_RATE = 34657312692978;         // in WEI
    uint256 public constant MAX_GAS_PRICE = 30 * (10 ** 9);             // 30 gwei (in wei)

    uint256 public constant SALE_START_DATE = 1513350000;               // in unix timestamp Dec 15th @ 15:00 CET
    uint256 public constant WHITELIST_END_DATE = SALE_START_DATE + 24 hours;  // End whitelist 24 hours after sale start date/time
    uint256 public constant SALE_END_DATE = SALE_START_DATE + 4 weeks;  // end sale in four weeks
    uint256 public constant UNFREEZE_DATE = SALE_START_DATE + 76 weeks; // Bounty0x Reserve locked for 18 months

    uint256 public constant PRESALE_POOL = 18950000;                    // 18.95M BNTY Pre-Sale Pool
    uint256 public constant MAINSALE_POOL = 90900000;                   // 90.9M BNTY for Main-Sale Pool
    uint256 public constant FOUNDER1_STAKE = 60000000;                  // 60M BNTY
    uint256 public constant FOUNDER2_STAKE = 45000000;                  // 45M BNTY
    uint256 public constant FOUNDER3_STAKE = 45000000;                  // 45M BNTY
    uint256 public constant BOUNTY0X_RESERVE= 225150000;                // 225.15M BNTY Bounty0x Reserve Pool
    uint256 public constant ADVISERS_POOL = 15000000;                   // 15M BNTY Advisers Pool
    uint256 public totalContributed;                                    // Total amount of ETH contributed in given period

    bool public tokenTransfersEnabled = false;                          // Transfer of tokens disabled till post-ICO
    bool public hardCapReached = false;                                 // If hard cap was reached
    bool public whitelistFilteringActive = true;                         // Whitelist filtering is defaulted true for first 24 hours
    bool private saleRunning;                                           // Check sale active

    uint256 private mainsaleTokensLeft = MAINSALE_POOL;                 // Used to check main sale tokens allocation pool is not exceeded

    // Vesting conditions
    uint public constant TEAM_VESTING_CLIFF = 0 weeks;                  // 1 week vesting cliff for founders and advisers
    uint public constant TEAM_VESTING_PERIOD = 52 weeks;                // 1 year vesting period for founders and advisers

    uint public constant ADVISERS_VESTING_CLIFF = 0 weeks;              // 1 week cliff for ADVISERS
    uint public constant ADVISERS_VESTING_PERIOD = 24 weeks;            // 6 months vesting cliff for ADVISERS

    mapping(address => TokenVesting) vestingContracts;

    // Events
    event OnCompensated(address contributor, uint amount);
    event OnContribution(uint totalContributed, address indexed contributor, uint amount, uint contributorsCount);
    event OnHardCapReached(uint endTime);

    function Bounty0xCrowdsale(address _multiSigWallet, address _founder1, address _founder2, address _founder3, address _bounty0xWallet, address[] _advisers) public {
        require(_advisers.length == 4);

        multiSigWallet = _multiSigWallet;
        advisers = _advisers;
        founder1 = _founder1;
        founder2 = _founder2;
        founder3 = _founder3;
        bounty0xWallet = _bounty0xWallet;
    }

    function () payable public whenNotPaused {
        require(saleRunning);
        require(tx.gasprice <= MAX_GAS_PRICE);

        // make sure tokens left is more than zero
        require(mainsaleTokensLeft >= 0);

        uint256 contributionAmount = msg.value;
        require(contributionAmount > 0);

        if (whitelistFilteringActive) {
            if (now < WHITELIST_END_DATE) {
                require(bounty0xToken.balanceOf(msg.sender).add(contributionAmount) <= maximumParticipationAmount);
                require(whitelistContributors[msg.sender]);
            } else if (now > WHITELIST_END_DATE) {
                increasePerCapAfterWhitelistPeriod();
            }
        }

        // calculate token amount to be minted and sent back to contributor
        uint256 numTokens = contributionAmount.div(MAINSALE_FIX_RATE);

        // Update tokens left in main sale pool
        mainsaleTokensLeft = mainsaleTokensLeft.sub(numTokens);

        // update funding state
        totalContributed = totalContributed.add(contributionAmount);

        // make sure total is not more than HARD_CAP
        require(totalContributed <= HARD_CAP_AMOUNT);

        // Transfer token to contributors address
        bounty0xToken.transfer(msg.sender, numTokens);
        OnCompensated(msg.sender, numTokens);
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
            .add(ADVISERS_POOL);

        // generate all the tokens that will need to be distributed
        require(bounty0xToken.generateTokens(this, totalSupply));

        // double check the supply is as expected, the maximum token supply of 500M
        assert(bounty0xToken.totalSupply() == MAXIMUM_TOKEN_SUPPLY);
    }

    // create the contract responsible for distributing presale bounties based on the presale contract
    function createBounty0xPresaleDistributor(Bounty0xPresaleI bounty0xPresale) public onlyOwner returns (bool success) {
        require(presaleDistributor == address(0));
        require(bounty0xToken != address(0));

        // create a presale distributor contract
        presaleDistributor = new Bounty0xPresaleDistributor(bounty0xToken, bounty0xPresale);

        // fund the presale distributor
        bounty0xToken.transfer(presaleDistributor, PRESALE_POOL.mul(10 ** 18));

        return true;
    }

    // create the vesting contracts for the advisers
    function distributeAdviserTokens() public onlyOwner returns (bool success) {
        uint distributionAmount = ADVISERS_POOL.mul(10 ** 18).div(advisers.length);

        for (uint i = 0; i < advisers.length; i++) {
            require(vestingContracts[advisers[i]] == address(0));

            TokenVesting vesting = new TokenVesting(advisers[i], SALE_START_DATE, SALE_START_DATE + ADVISERS_VESTING_CLIFF, ADVISERS_VESTING_PERIOD, false);
            bounty0xToken.transfer(address(vesting), distributionAmount);

            vestingContracts[advisers[i]] = vesting;
        }

        return true;
    }

    // create the vesting contracts for the founder tokens
    function distributeFounderTokens() public onlyOwner returns (bool success) {
        require(vestingContracts[founder1] == address(0));
        require(vestingContracts[founder2] == address(0));
        require(vestingContracts[founder3] == address(0));

        TokenVesting vestingFounder1 = new TokenVesting(founder1, SALE_START_DATE, SALE_START_DATE + TEAM_VESTING_CLIFF, TEAM_VESTING_PERIOD, false);
        bounty0xToken.transfer(address(vestingFounder1), FOUNDER1_STAKE.mul(10 ** 18));
        vestingContracts[founder1] = vestingFounder1;

        TokenVesting vestingFounder2 = new TokenVesting(founder2, SALE_START_DATE, SALE_START_DATE + TEAM_VESTING_CLIFF, TEAM_VESTING_PERIOD, false);
        bounty0xToken.transfer(address(vestingFounder2), FOUNDER2_STAKE.mul(10 ** 18));
        vestingContracts[founder2] = vestingFounder2;

        TokenVesting vestingFounder3 = new TokenVesting(founder3, SALE_START_DATE, SALE_START_DATE + TEAM_VESTING_CLIFF, TEAM_VESTING_PERIOD, false);
        bounty0xToken.transfer(address(vestingFounder3), FOUNDER3_STAKE.mul(10 ** 18));
        vestingContracts[founder3] = vestingFounder3;

        return true;
    }

    // @notice Kill method should not really be needed, but just in case
    function kill(address _to) onlyOwner external {
        selfDestruct(_to);
    }

    // Internal function to increase per person cap to $10k after first 24 hours of crowdsale
    function increasePerCapAfterWhitelistPeriod() internal {
        maximumParticipationAmount = 21 ether;
        whitelistFilteringActive = false;
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
        return canTransfer(_from);
    }

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {
        return canTransfer(_owner);
    }

    function canTransfer(address sender) private view returns (bool) {
        if (tokenTransfersEnabled) {
            return true;
        }

        // until token transfers are enabled, only this crowdsale contract and the presale distributor may transfer
        // tokens
        return sender == address(this) || sender == address(presaleDistributor);
    }

}