pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/Timelock.sol';
import './KnowsConstants.sol';

// Contract holder for the reserves
// has additional function that allows it to add team members, that will all have the same vesting period so as
// to prevent the contract from being called to release tokens early
contract Bounty0xReserveHolder is TokenTimelock, KnowsConstants {
    function Bounty0xReserveHolder(){
    }

    function addTeamMember(address wallet) {
    }
}
