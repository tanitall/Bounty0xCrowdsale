pragma solidity ^0.4.18;


import '../Bounty0xCrowdsale.sol';
import './MockKnowsTime.sol';


// Mock presale contract used for testing the presale distributor
contract MockBounty0xCrowdsale is Bounty0xCrowdsale, MockKnowsTime {
    function MockBounty0xCrowdsale(Bounty0xToken _bounty0xToken, uint _USDEtherPrice, Bounty0xPresaleI _bounty0xPresale)
        Bounty0xCrowdsale(_bounty0xToken, _USDEtherPrice, _bounty0xPresale)
        public
    {
    }
}
