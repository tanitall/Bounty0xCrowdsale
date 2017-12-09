pragma solidity ^0.4.18;


import '../BntyExchangeRateCalculator.sol';
import './MockKnowsTime.sol';


// Just overwrites the currentTime() method so we can change the time for mocks
contract MockBntyExchangeRateCalculator is BntyExchangeRateCalculator, MockKnowsTime {
    function MockBntyExchangeRateCalculator(uint _bntyMicrodollarPrice, uint _USDEtherPrice, uint _fixUSDPriceTime)
    BntyExchangeRateCalculator(_bntyMicrodollarPrice, _USDEtherPrice, _fixUSDPriceTime)
    public
    {}
}
