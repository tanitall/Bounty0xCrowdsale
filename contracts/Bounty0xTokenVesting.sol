pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/TokenVesting.sol';
import './KnowsConstants.sol';

contract Bounty0xTokenVesting is KnowsConstants, TokenVesting {
    function Bounty0xTokenVesting(address _beneficiary, uint durationWeeks)
        TokenVesting(_beneficiary, VESTING_START_DATE, 0, durationWeeks * 1 weeks, false)
        public
    {
    }
}
