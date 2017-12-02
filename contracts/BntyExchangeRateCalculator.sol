pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

// This contract does the math to figure out the BNTY paid per WEI, based on the fixed USD ether price
// It is only used for the crowdsale contract
contract BntyExchangeRateCalculator {
    using SafeMath for uint;

    uint public constant WEI_PER_ETH = 10 ** 18;

    uint public weiPerUSD;
    uint public bntyPerWei;

    // a microdollar is one millionth of a dollar, or one ten-thousandth of a cent
    function BntyExchangeRateCalculator(uint _bntyMicrocentPrice, uint _fixedUSDEtherPrice) public {
        weiPerUSD = WEI_PER_ETH.div(_fixedUSDEtherPrice);

        bntyPerWei =
            _fixedUSDEtherPrice
                // first convert to micropennies per ETH by multiplying by 1 million
                .mul(10 ** 6)
                // then divide by micro pennies per bnty to get ETH per BNTY
                .div(_bntyMicrocentPrice);
    }

    function usdToWei(uint usd) view public returns (uint) {
        return weiPerUSD.mul(usd);
    }

    // returns the number of bnty per some amount in wei
    function weiToBnty(uint amtWei) view public returns (uint) {
        return bntyPerWei.mul(amtWei);
    }
}
