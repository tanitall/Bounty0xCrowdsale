pragma solidity ^0.4.18;

import './KnowsConstants.sol';
import 'zeppelin-solidity/contracts/token/TokenTimelock.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

// Contract that holds the reserves
// has additional function that allows the owner to add team members,
// distributing some of the reserves to a vested token contract
contract Bounty0xReserveHolder is TokenTimelock, KnowsConstants, Ownable {
    function Bounty0xReserveHolder() public {
    }

    function addTeamMember(address wallet) public onlyOwner {
    }
}
