pragma solidity ^0.4.18;

import '../Bounty0xReserveHolder.sol';
import './MockKnowsTime.sol';

// Just overwrites the currentTime() method so we can change the time for mocks
contract MockBounty0xReserveHolder is Bounty0xReserveHolder, MockKnowsTime {
    function MockBounty0xReserveHolder(Bounty0xToken _token, address _beneficiary)
        Bounty0xReserveHolder(_token, _beneficiary)
        public
    {}
}
