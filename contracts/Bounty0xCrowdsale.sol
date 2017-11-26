pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Bounty0xToken.sol";
import "./Bounty0xPresale.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./minime_interface/TokenController.sol";

contract Bounty0xContribution is Pausable, TokenController {
    using SafeMath for uint256;

    Bounty0xPresale constant public PRESALE_DEPLOYED = Bounty0xPresale(0x998C31DBAD9567Df0DDDA990C0Df620B79F559ea);
    Bounty0xToken public bounty0xToken;                                 // Reward tokens to compensate in
    address public founder1;                                            // Wallet of founder 1
    address public founder2;                                            // Wallet of founder 2
    address public founder3;                                            // Wallet of founder 3  
    address public bounty0xWallet;                                      // Bounty0x Wallet  
    address[] public advisers;                                          // 4 Wallets of advisors
    address[] public preSaleInvestors;                                  // Array of all whitelisted investors
    address[] public whitelistArray;
    mapping (address => bool) public whitelistContributors;

    // Crowdsale Conditions
    mapping (address => uint256) public contributors; 
    uint256 public maximumParticipationAmount = 3.16 ether;             // Maximum initial constribution cap per person
    uint256 public constant MINIMUM_PARTICIPATION_AMOUNT = 0.1 ether;   // IN ETH minimum one can contribute
    uint256 public constant MAXIMUM_TOKEN_SUPPLY = 500000000 * (10 ** uint256(18));           // maximum BNTY tokens to be minted at any given point
    uint256 public constant HARD_CAP_AMOUNT = 3260 ether;               // in ETH 
    uint256 public constant PRESALE_FIX_RATE = 27725850154382;      // in WEI
    uint256 public constant MAINSALE_FIX_RATE = 34657312692978;     // in WEI
    uint256 public constant MAX_GAS_PRICE = 20000000000;                // 20 gwei (in wei)
    uint256 public constant SALE_START_DATE = 1513350000;               // in unix timestamp Dec 15th @ 15:00 CET
    uint256 public constant SALE_END_DATE = SALE_START_DATE + 4 weeks;  // end sale in four weeks
    uint256 public constant UNFREEZE_DATE = SALE_START_DATE + 76 weeks; // Bounty0x Reserve locked for 18 months
    uint256 public constant PRESALE_POOL = 18950000;                    // 19.5M BNTY Pre-Sale Pool
    uint256 public constant MAINSALE_POOL = 90900000;                   // 93.75M BNTY for Main-Sale Pool
    uint256 public constant FOUNDER1_STAKE = 60000000;                  // 60M BNTY
    uint256 public constant FOUNDER2_STAKE = 45000000;                  // 45M BNTY
    uint256 public constant FOUNDER3_STAKE = 45000000;                  // 45M BNTY
    uint256 public constant BOUNTY0X_RESERVE = 225150000;               // 221.75M BNTY Bounty0x Reserve Pool
    uint256 public constant ADVISORS_POOL = 15000000;                   // 15M BNTY Advisors Pool
    uint256 public totalContributed;                                    // Total amount of ETH contributed in given period
    uint256 public preSaleCompensationCounter;
    
    bool public tokenTransfersEnabled = false;                          // Transfer of tokens disabled till post-ICO
    bool public hardCapReached = false;                                 // If hard cap was reached
    bool private saleRunning;                                           // Check sale active
    bool private whitelistIsActive = true;                              // Whitelist is active first 24
    uint256 private mainsaleTokensLeft = MAINSALE_POOL;                 // Used to check main sale tokens allocation pool is not exceeded
    uint256 private preSaleTokensLeft = PRESALE_POOL;

    // Vesting conditions
    uint public constant TEAM_VESTING_CLIFF = 1 weeks;                  // 1 week vesting cliff for founders and advisors
    uint public constant TEAM_VESTING_PERIOD = 52 weeks;                // 1 year vesting period for founders and advisors 

    uint public constant ADVISERS_VESTING_CLIFF = 1 weeks;              // 1 week cliff for ADVISERS
    uint public constant ADVISERS_VESTING_PERIOD = 24 weeks;            // 6 months vesting cliff for ADVISERS

    // Events
    event OnCompensated(address contributor, uint amount);
    event OnPreSaleBuyerCompensated(address contributor, uint amount);
    event OnContribution(uint totalContributed, address indexed contributor, uint amount, uint contributorsCount);
    event OnHardCapReached(uint endTime);

    function Bounty0xContribution(address _founder1, address _founder2, address _founder3, address _bounty0xWallet, address[] _advisers, address[] _preSaleInvestors, address[] _whitelistArray) {
        require(_advisers.length == 4);
        founder1 = _founder1;
        founder2 = _founder2;
        founder3 = _founder3;
        bounty0xWallet = _bounty0xWallet;
        advisers = _advisers;
        preSaleInvestors = _preSaleInvestors;
        whitelistArray = _whitelistArray;
    }


    function contribute() payable stopInEmergency {
        contributeWithAddress(msg.sender);
    }

    function contributeWithAddress(address contributor) payable stopInEmergency {
        require(saleRunning);
        require(tx.gasprice <= MAX_GAS_PRICE);
        
        // make sure tokens left is more than zero
        require(mainsaleTokensLeft >= 0);

        uint256 contributionAmount = msg.value;
        require(contributionAmount > 0);
        
        if (whitelistIsActive) {
            require(bounty0xToken.balanceOf(contributor).add(contributionAmount) <= maximumParticipationAmount);
            require(whitelistContributors[contributor]);
        }

        // calculate token amount to be minted and sent back to contributor
        uint256 tokens = contributionAmount.div(MAINSALE_FIX_RATE);

        // Update tokens left in main sale pool
        mainsaleTokensLeft = mainsaleTokensLeft.sub(tokens);
        
        // update funding state
        totalContributed = totalContributed.add(contributionAmount);

        // make sure total is not more than HARD_CAP
        require(totalContributed <= HARD_CAP_AMOUNT);

        // Transfer token to contributors address
        bounty0xToken.transfer(contributor, tokens);
        OnCompensated(contributor, tokens);
    }

    //  @notice Sets Bounty0xToken contract
    //  Generates all BNTY tokens and assigns them to this contract
    //  If token contract has already generated tokens, do not generate again
    //  @param _Bounty0xToken Bounty0xToken address
    function setBounty0xToken(address _bounty0xToken) public onlyOwner {
        require(_bounty0xToken != 0x0);
        require(!saleRunning);
        bounty0xToken = Bounty0xToken(_bounty0xToken);
        if (bounty0xToken.totalSupply() == 0) {
            bounty0xToken.generateTokens(this, MAINSALE_POOL
                .add(PRESALE_POOL)
                .add(FOUNDER1_STAKE)
                .add(FOUNDER2_STAKE)
                .add(FOUNDER3_STAKE)
                .add(BOUNTY0X_RESERVE)
                .add(ADVISORS_POOL));
        }
        require(bounty0xToken.totalSupply() == MAXIMUM_TOKEN_SUPPLY);
    }

    // @notice Method for setting up contribution period
    //  Only owner should be able to execute
    //  Setting first contribution period sets up vesting for founders & advisors
    //  Contribution period should still not be enabled after calling this method
    function setContribPeriod() onlyOwner {
        require(!saleRunning);

        /*
        bounty0xToken.revokeAllTokenGrants(founder1);
        bounty0xToken.revokeAllTokenGrants(founder2);
        bounty0xToken.revokeAllTokenGrants(founder3);
        bounty0xToken.revokeAllTokenGrants(bounty0xWallet);

        for (uint j = 0; j < advisers.length; j++) {
            bounty0xToken.revokeAllTokenGrants(advisers[j]);
        }
                */

        uint64 vestingDate = uint64(SALE_START_DATE.add(TEAM_VESTING_PERIOD));
        uint64 cliffDate = uint64(SALE_START_DATE.add(TEAM_VESTING_CLIFF));
        uint64 adviserContribVestingDate = uint64(SALE_START_DATE.add(ADVISERS_VESTING_PERIOD));
        uint64 adviserContribCliffDate = uint64(SALE_START_DATE.add(ADVISERS_VESTING_CLIFF));
        uint64 startDate = uint64(SALE_START_DATE);

        bounty0xToken.grantVestedTokens(founder1, FOUNDER1_STAKE, startDate, cliffDate, vestingDate, true, false);
        bounty0xToken.grantVestedTokens(founder2, FOUNDER2_STAKE, startDate, cliffDate, vestingDate, true, false);
        bounty0xToken.grantVestedTokens(founder3, FOUNDER3_STAKE, startDate, cliffDate, vestingDate, true, false);
        bounty0xToken.grantVestedTokens(advisers[1], ADVISORS_POOL, startDate, adviserContribCliffDate, adviserContribVestingDate, true, false);
        bounty0xToken.grantVestedTokens(advisers[2], ADVISORS_POOL, startDate, adviserContribCliffDate, adviserContribVestingDate, true, false);
        bounty0xToken.grantVestedTokens(advisers[2], ADVISORS_POOL, startDate, adviserContribCliffDate, adviserContribVestingDate, true, false);
        bounty0xToken.grantVestedTokens(advisers[2], ADVISORS_POOL, startDate, adviserContribCliffDate, adviserContribVestingDate, true, false);

        //TokenTimelock(BOUNTY0X_RESERVE, bounty0xWallet, UNFREEZE_DATE);
    }

    function distributePreSaleContributions() public onlyOwner {
        for (uint x = 0; x < preSaleInvestors.length; x++) {
            address investorsAddress = preSaleInvestors[x];
            assert(PRESALE_DEPLOYED.balanceOf(investorsAddress) == 0x0);
            compensatePresale(investorsAddress, PRESALE_DEPLOYED.balanceOf(investorsAddress));
        }
    }

    function compensatePresale(address contributor, uint256 value) internal {
        assert(value > 0);
        assert(preSaleTokensLeft > 0);

        // calculate token amount to be minted and sent back to contributor
        uint256 tokens = value.div(PRESALE_FIX_RATE);

        // Update tokens left in main sale pool
        preSaleTokensLeft = preSaleTokensLeft.sub(tokens);
        
        // update funding state
        preSaleCompensationCounter = preSaleCompensationCounter.add(value);

        // update funding state
        totalContributed = totalContributed.add(value);

        // make sure total is not more than HARD_CAP
        require(totalContributed <= HARD_CAP_AMOUNT);

        // make sure total is not more than HARD_CAP
        require(preSaleCompensationCounter <= PRESALE_POOL);

        // Transfer token to contributors address
        bounty0xToken.transfer(contributor, value);
        OnPreSaleBuyerCompensated(contributor, value);
    }

    function whitelistAddress () public onlyOwner {
        for (uint i = 0; i < whitelistArray.length; i++) {
            whitelistContributors[whitelistArray[i]] = true;
        }
    }
}