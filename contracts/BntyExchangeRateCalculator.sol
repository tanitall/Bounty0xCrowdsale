pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

// This contract does the math to figure out the BNTY paid per WEI, based on the fixed USD ether price
contract BntyExchangeRateCalculator {
    using SafeMath for uint;

    // a microdollar is one millionth of a dollar, or one ten-thousandth of a cent
    uint public constant MICRO_DOLLARS_PER_BNTY_PRESALE = 16500;
    uint public constant MICRO_DOLLARS_PER_BNTY = 13200;

    uint public fixedUSDEtherPrice;
    uint public bntyPerWei;

    function BntyExchangeRateCalculator(uint _fixedUSDEtherPrice) public {
        fixedUSDEtherPrice = _fixedUSDEtherPrice;

        bntyPerWei =
            fixedUSDEtherPrice
                // first convert to micropennies per ETH by multiplying by 1 million
                .mul(10**6)
                // then divide by micro pennies per bnty to get ETH per BNTY
                .div(MICRO_DOLLARS_PER_BNTY);

    }

    function usdToWei(uint usd) view public returns (uint) {
        return usd.mul(100).mul(10**18).div(fixedUSDEtherPrice).div(100);
    }

    // returns the number of bnty per some amount in wei
    function weiToBnty(uint amtWei) view public returns (uint) {
        return bntyPerWei.mul(amtWei);
    }
}
