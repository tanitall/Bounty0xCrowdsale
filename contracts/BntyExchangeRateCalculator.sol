pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './KnowsTime.sol';

// This contract does the math to figure out the BNTY paid per WEI, based on the fixed USD ether price
contract BntyExchangeRateCalculator is KnowsTime, Ownable {
    using SafeMath for uint;

    uint public constant WEI_PER_ETH = 10 ** 18;

    uint public bntyMicrodollarPrice;
    uint public fixedUSDEtherPrice;
    uint public priceCanChangeUntil;

    // a microdollar is one millionth of a dollar, or one ten-thousandth of a cent
    function BntyExchangeRateCalculator(uint _bntyMicrodollarPrice, uint _fixedUSDEtherPrice, uint _priceCanChangeUntil)
        public
    {
        require(_bntyMicrodollarPrice > 0);
        require(_fixedUSDEtherPrice > 0);

        bntyMicrodollarPrice = _bntyMicrodollarPrice;
        priceCanChangeUntil = _priceCanChangeUntil;
        fixedUSDEtherPrice = _fixedUSDEtherPrice;
    }

    // the owner can change the usd ether price
    function setUSDEtherPrice(uint _fixedUSDEtherPrice) onlyOwner public {
        require(currentTime() < priceCanChangeUntil);
        require(_fixedUSDEtherPrice > 0);

        fixedUSDEtherPrice = _fixedUSDEtherPrice;
    }

    // returns the number of wei some amount of usd
    function usdToWei(uint usd) view public returns (uint) {
        return WEI_PER_ETH.mul(usd).div(fixedUSDEtherPrice);
    }

    // returns the number of bnty per some amount in wei
    function weiToBnty(uint amtWei) view public returns (uint) {
        return fixedUSDEtherPrice.mul(10 ** 6).mul(amtWei).div(bntyMicrodollarPrice);
    }
}
