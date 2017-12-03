pragma solidity ^0.4.18;

import '../interfaces/Bounty0xPresaleI.sol';

// Mock presale contract used for testing the presale distributor
contract MockBounty0xPresale is Bounty0xPresaleI {

    mapping (address => uint) public contributions;

    function MockBounty0xPresale(address[] contributors, uint[] amounts) public {
        for (uint i = 0; i < contributors.length; i++) {
            contributions[contributors[i]] = amounts[i];
        }
    }

    function balanceOf(address addr) public returns (uint balance) {
        return contributions[addr];
    }

}
