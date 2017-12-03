pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

// This contract does the math to figure out the BNTY paid per WEI, based on the fixed USD ether price
contract BntyExchangeRateCalculator {
    using SafeMath for uint;

    uint public constant WEI_PER_ETH = 10 ** 18;

    uint public weiPerUSD;
    uint public bntyPerWei;

    // a microdollar is one millionth of a dollar, or one ten-thousandth of a cent
    function BntyExchangeRateCalculator(uint _bntyMicrodollarPrice, uint _fixedUSDEtherPrice) public {
        weiPerUSD = WEI_PER_ETH.div(_fixedUSDEtherPrice);

        bntyPerWei =
            _fixedUSDEtherPrice
                // first convert to microdollars per ETH by multiplying by 1 million
                .mul(10 ** 6)
                // then divide by microdollars per bnty to get ETH per BNTY
                .div(_bntyMicrodollarPrice);
    }

    function usdToWei(uint usd) view public returns (uint) {
        return weiPerUSD.mul(usd);
    }

    // returns the number of bnty per some amount in wei
    function weiToBnty(uint amtWei) view public returns (uint) {
        return bntyPerWei.mul(amtWei);
    }
}
