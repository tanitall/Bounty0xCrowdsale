pragma solidity ^0.4.11;

import "./SafeMath.sol";
import "./Bounty0xToken.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./minime_interface/TokenController.sol";

contract Bounty0xContribution is Pausable, TokenController {
    using SafeMath for uint;

    Bounty0xToken public bounty0xToken;                                 // Reward tokens to compensate in
    address public multisigWallet;                                      // Wallet that receives all sale funds and BountyIO Stakes
    address public founder1;                                            // Wallet of founder 1
    address public founder2;                                            // Wallet of founder 2
    address public founder3;                                            // Wallet of founder 3    
    address[] public advisers;                                          // 4 Wallets of advisors

    uint public constant FOUNDER1_STAKE = 70000000 ether;               // 80M BNTY
    uint public constant FOUNDER2_STAKE = 45000000 ether;               // 60M BNTY
    uint public constant FOUNDER3_STAKE = 45000000 ether;               // 60M BNTY =160M
    uint public constant ADVISERS_STAKE = 15000000 ether;               // 15M BNTY
    uint public constant BOUNTY_FUNDS_STAKE = 75000000 ether;           // 75M BNTY
    uint public constant CONTRIB_PERIOD1_STAKE = 250000000 ether;       // 250M BNTY

    
    uint public minContribAmount = 0.01 ether;                          // 0.01 ether
    uint public maxGasPrice = 50000000000;                              // 50 GWei

    uint public constant TEAM_VESTING_CLIFF = 24 weeks;                 // 6 months vesting cliff for founders and advisors
    uint public constant TEAM_VESTING_PERIOD = 96 weeks;                // 2 years vesting period for founders and advisors 

    uint public constant ADVISERS_VESTING_CLIFF = 12 weeks;             // 3 months cliff for ADVISERS
    uint public constant ADVISERS_VESTING_PERIOD = 24 weeks;            // 6 months vesting cliff for ADVISERS

    bool public tokenTransfersEnabled = false;                          // BNTY token transfers will be enabled manually
                                                                        // after first contribution period
                                                                        // Can't be disabled back
    struct Contributor {
        uint amount;                        // Amount of ETH contributed by an address in given contribution period
        bool isCompensated;                 // Whether this contributor received BNTY token for ETH contribution
        uint amountCompensated;             // Amount of BNTY received. Not really needed to store,
                                            // but stored for accounting and security purposes
    }

    uint public softCapAmount;                                 // Soft cap of contribution period in wei
    uint public afterSoftCapDuration;                          // Number of seconds to the end of sale from the moment of reaching soft cap (unless reaching hardcap)
    uint public hardCapAmount;                                 // When reached this amount of wei, the contribution will end instantly
    uint public startTime;                                     // Start time of contribution period in UNIX time
    uint public endTime;                                       // End time of contribution period in UNIX time
    bool public isEnabled;                                     // If contribution period was enabled by multisignature
    bool public softCapReached;                                // If soft cap was reached
    bool public hardCapReached;                                // If hard cap was reached
    uint public totalContributed;                              // Total amount of ETH contributed in given period
    address[] public contributorsKeys;                         // Addresses of all contributors in given contribution period
    mapping (address => Contributor) public contributors;

    event onContribution(uint totalContributed, address indexed contributor, uint amount, uint contributorsCount);
    event onSoftCapReached(uint endTime);
    event onHardCapReached(uint endTime);
    event onCompensated(address indexed contributor, uint amount);

    modifier onlyMultisig() {
        require(multisigWallet == msg.sender);
        _;
    }

    function Bounty0xContribution(
        address _multisigWallet,
        address _founder1,
        address _founder2,
        address _founder3,
        address[] _advisers
    ) {
        require(_advisers.length == 5);
        multisigWallet = _multisigWallet;
        founder1 = _founder1;
        founder2 = _founder2;
        advisers = _advisers;
    }
    
    // @notice Returns true if contribution period is currently running
    function isContribPeriodRunning() constant returns (bool) {
        return !hardCapReached && isEnabled && startTime <= now && endTime > now;
    }

    function contribute()
        payable
        stopInEmergency
    {
        contributeWithAddress(msg.sender);
    }

    // @notice Function to participate in contribution period
    //  Amounts from the same address should be added up
    //  If soft or hard cap is reached, end time should be modified
    //  Funds should be transferred into multisig wallet
    // @param contributor Address that will receive BNTY token
    function contributeWithAddress(address contributor)
        payable
        stopInEmergency
    {
        require(tx.gasprice <= maxGasPrice);
        require(msg.value >= minContribAmount);
        require(isContribPeriodRunning());

        uint contribValue = msg.value;
        uint excessContribValue = 0;

        uint oldTotalContributed = totalContributed;

        totalContributed = oldTotalContributed.add(contribValue);

        uint newTotalContributed = totalContributed;

        // Soft cap was reached
        if (newTotalContributed >= softCapAmount &&
            oldTotalContributed < softCapAmount)
        {
            softCapReached = true;
            endTime = afterSoftCapDuration.add(now);
            onSoftCapReached(endTime);
        }
        // Hard cap was reached
        if (newTotalContributed >= hardCapAmount &&
            oldTotalContributed < hardCapAmount)
        {
            hardCapReached = true;
            endTime = now;
            onHardCapReached(endTime);

            // Everything above hard cap will be sent back to contributor
            excessContribValue = newTotalContributed.sub(hardCapAmount);
            contribValue = contribValue.sub(excessContribValue);

            totalContributed = hardCapAmount;
        }

        if (contributors[contributor].amount == 0) {
            contributorsKeys.push(contributor);
        }

        contributors[contributor].amount = contributors[contributor].amount.add(contribValue);

        multisigWallet.transfer(contribValue);
        if (excessContribValue > 0) {
            msg.sender.transfer(excessContribValue);
        }
        onContribution(newTotalContributed, contributor, contribValue, contributorsKeys.length);
    }

    // @notice This method is called by owner after contribution period ends, to distribute BNTY in proportional manner
    //  Each contributor should receive BNTY just once even if this method is called multiple times
    //  In case of many contributors must be able to compensate contributors in paginational way, otherwise might
    //  run out of gas if wanted to compensate all on one method call. Therefore parameters offset and limit
    // @param periodIndex Index of contribution period (0-2)
    // @param offset Number of first contributors to skip.
    // @param limit Max number of contributors compensated on this call
    function compensateContributors(uint offset, uint limit)
        onlyOwner
    {
        require(isEnabled);
        require(endTime < now);

        uint i = offset;
        uint compensatedCount = 0;
        uint contributorsCount = contributorsKeys.length;

        uint ratio = CONTRIB_PERIOD1_STAKE
            .mul(1000000000000000000)
            .div(totalContributed);

        while (i < contributorsCount && compensatedCount < limit) {
            address contributorAddress = contributorsKeys[i];
            if (!contributors[contributorAddress].isCompensated) {
                uint amountContributed = contributors[contributorAddress].amount;
                contributors[contributorAddress].isCompensated = true;

                contributors[contributorAddress].amountCompensated = amountContributed.mul(ratio).div(1000000000000000000);

                bounty0xToken.transfer(contributorAddress, contributors[contributorAddress].amountCompensated);
                onCompensated(contributorAddress, contributors[contributorAddress].amountCompensated);

                compensatedCount++;
            }
            i++;
        }
    }

    // @notice Method for setting up contribution period
    //  Only owner should be able to execute
    //  Setting first contribution period sets up vesting for founders & advisors
    //  Contribution period should still not be enabled after calling this method
    // @param softCapAmount Soft Cap in wei
    // @param afterSoftCapDuration Number of seconds till the end of sale in the moment of reaching soft cap (unless reaching hard cap)
    // @param hardCapAmount Hard Cap in wei
    // @param startTime Contribution start time in UNIX time
    // @param endTime Contribution end time in UNIX time
    function setContribPeriod(
        uint _softCapAmount,
        uint _afterSoftCapDuration,
        uint _hardCapAmount,
        uint _startTime,
        uint _endTime
    )
        onlyOwner
    {
        require(_softCapAmount > 0);
        require(_hardCapAmount > _softCapAmount);
        require(_afterSoftCapDuration > 0);
        require(_startTime > now);
        require(_endTime > _startTime);
        require(!isEnabled);

        softCapAmount = _softCapAmount;
        afterSoftCapDuration = _afterSoftCapDuration;
        hardCapAmount = _hardCapAmount;
        startTime = _startTime;
        endTime = _endTime;

        bounty0xToken.revokeAllTokenGrants(founder1);
        bounty0xToken.revokeAllTokenGrants(founder2);
        bounty0xToken.revokeAllTokenGrants(founder3);


        for (uint j = 0; j < advisers.length; j++) {
            bounty0xToken.revokeAllTokenGrants(advisers[j]);
        }

        uint64 vestingDate = uint64(startTime.add(TEAM_VESTING_PERIOD));
        uint64 cliffDate = uint64(startTime.add(TEAM_VESTING_CLIFF));
        uint64 adviserContribVestingDate = uint64(startTime.add(ADVISERS_VESTING_PERIOD));
        uint64 adviserContribCliffDate = uint64(startTime.add(ADVISERS_VESTING_CLIFF));
        uint64 startDate = uint64(startTime);

        bounty0xToken.grantVestedTokens(founder1, FOUNDER1_STAKE, startDate, cliffDate, vestingDate, true, false);
        bounty0xToken.grantVestedTokens(founder2, FOUNDER2_STAKE, startDate, cliffDate, vestingDate, true, false);
        bounty0xToken.grantVestedTokens(founder3, FOUNDER3_STAKE, startDate, cliffDate, vestingDate, true, false);
        bounty0xToken.grantVestedTokens(advisers[1], ADVISERS_STAKE, startDate, adviserContribCliffDate, adviserContribVestingDate, true, false);
        bounty0xToken.grantVestedTokens(advisers[2], ADVISERS_STAKE, startDate, adviserContribCliffDate, adviserContribVestingDate, true, false);
    }

    // @notice Enables contribution period
    //  Must be executed by multisignature
    function enableContribPeriod()
        onlyMultisig
    {
        require(startTime > now);
        isEnabled = true;
    }

    // @notice Sets new min. contribution amount
    //  Only owner can execute
    //  Cannot be executed while contribution period is running
    // @param _minContribAmount new min. amount
    function setMinContribAmount(uint _minContribAmount)
        onlyOwner
    {
        require(_minContribAmount > 0);
        require(startTime > now);
        minContribAmount = _minContribAmount;
    }

    // @notice Sets new max gas price for contribution
    //  Only owner can execute
    //  Cannot be executed while contribution period is running
    // @param _minContribAmount new min. amount
    function setMaxGasPrice(uint _maxGasPrice)
        onlyOwner
    {
        require(_maxGasPrice > 0);
        require(startTime > now);
        maxGasPrice = _maxGasPrice;
    }

    // @notice Sets Bounty0xToken contract
    //  Generates all BNTY tokens and assigns them to this contract
    //  If token contract has already generated tokens, do not generate again
    // @param _Bounty0xToken Bounty0xToken address
    function setBounty0xToken(address _bounty0xToken)
        onlyOwner
    {
        require(_bounty0xToken != 0x0);
        require(!isEnabled);
        bounty0xToken = Bounty0xToken(_bounty0xToken);
        if (bounty0xToken.totalSupply() == 0) {
            bounty0xToken.generateTokens(this, FOUNDER1_STAKE
                .add(FOUNDER2_STAKE)
                .add(FOUNDER3_STAKE)
                .add(ADVISERS_STAKE.mul(2))
                .add(CONTRIB_PERIOD1_STAKE));
        }
    }

    // @notice Enables transfers of BNTY
    //  Will be executed after first contribution period by owner
    function enableBounty0xTokenTransfers()
        onlyOwner
    {
        require(endTime < now);
        tokenTransfersEnabled = true;
    }

    // @notice Method to claim tokens accidentally sent to a BNTY contract
    //  Only multisig wallet can execute
    // @param _token Address of claimed ERC20 Token
    function claimTokensFromTokenBounty0xToken(address _token)
        onlyMultisig
    {
        bounty0xToken.claimTokens(_token, multisigWallet);
    }

    // @notice Kill method should not really be needed, but just in case
    function kill(address _to) onlyMultisig external {
        selfdestruct(_to);
    }

    function()
        payable
        stopInEmergency
    {
        contributeWithAddress(msg.sender);
    }

    // MiniMe Controller default settings for allowing token transfers.
    function proxyPayment(address _owner) payable public returns (bool) {
        throw;
    }

    // Before transfers are enabled for everyone, only this contract is allowed to distribute BNTY
    function onTransfer(address _from, address _to, uint _amount) public returns (bool) {
        return tokenTransfersEnabled || _from == address(this) || _to == address(this);
    }

    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {
        return tokenTransfersEnabled;
    }

    function isTokenSaleToken(address tokenAddr) returns(bool) {
        return bounty0xToken == tokenAddr;
    }

    /*
     Following constant methods are used for tests and contribution web app
     They don't impact logic of contribution contract, therefor DOES NOT NEED TO BE AUDITED
     */

    // Used by contribution front-end to obtain contribution period properties
    function getContribPeriod()
        constant
        returns (bool[3] boolValues, uint[8] uintValues)
    {
        boolValues[0] = isEnabled;
        boolValues[1] = softCapReached;
        boolValues[2] = hardCapReached;

        uintValues[0] = softCapAmount;
        uintValues[1] = afterSoftCapDuration;
        uintValues[2] = hardCapAmount;
        uintValues[3] = startTime;
        uintValues[4] = endTime;
        uintValues[5] = totalContributed;
        uintValues[6] = contributorsKeys.length;
        uintValues[7] = CONTRIB_PERIOD1_STAKE;

        return (boolValues, uintValues);
    }

    // Used by contribution front-end to obtain contribution contract properties
    function getConfiguration()
        constant
        returns (bool, address, address, address, address, address[] _advisers, bool, uint)
    {
        _advisers = new address[](advisers.length);
        for (uint i = 0; i < advisers.length; i++) {
            _advisers[i] = advisers[i];
        }
        return (stopped, multisigWallet, founder1, founder2, founder3, _advisers, tokenTransfersEnabled, maxGasPrice);
    }

    // Used by contribution front-end to obtain contributor's properties
    function getContributor(address contributorAddress)
        constant
        returns(uint, bool, uint)
    {
        Contributor contributor = contributors[contributorAddress];
        return (contributor.amount, contributor.isCompensated, contributor.amountCompensated);
    }

    // Function to verify if all contributors were compensated
    function getUncompensatedContributors(uint offset, uint limit)
        constant
        returns (uint[] contributorIndexes)
    {
        uint contributorsCount = contributorsKeys.length;

        if (limit == 0) {
            limit = contributorsCount;
        }

        uint i = offset;
        uint resultsCount = 0;
        uint[] memory _contributorIndexes = new uint[](limit);

        while (i < contributorsCount && resultsCount < limit) {
            if (!contributors[contributorsKeys[i]].isCompensated) {
                _contributorIndexes[resultsCount] = i;
                resultsCount++;
            }
            i++;
        }

        contributorIndexes = new uint[](resultsCount);
        for (i = 0; i < resultsCount; i++) {
            contributorIndexes[i] = _contributorIndexes[i];
        }
        return contributorIndexes;
    }

    function getNow()
        constant
        returns(uint)
    {
        return now;
    }
}