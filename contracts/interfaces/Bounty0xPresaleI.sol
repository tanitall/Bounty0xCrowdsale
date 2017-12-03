pragma solidity ^0.4.18;

/**
 * This interface describes the only function we will be calling from the Bounty0xPresaleI contract
 */
interface Bounty0xPresaleI {
    function balanceOf(address) public returns (uint balance);
}
