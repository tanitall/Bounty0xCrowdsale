pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Bounty0xToken.sol';
import './interfaces/Bounty0xPresaleI.sol';
import './BntyExchangeRateCalculator.sol';
import './KnowsConstants.sol';

/*
This contract manages compensation of the presale investors, based on the contribution balances recorded in the presale
contract.
*/
contract Bounty0xPresaleDistributor is KnowsConstants, BntyExchangeRateCalculator, Ownable {
    using SafeMath for uint;

    Bounty0xPresaleI public deployedPresaleContract;
    Bounty0xToken public bounty0xToken;

    mapping(address => uint) public tokensPaid;

    function Bounty0xPresaleDistributor(Bounty0xToken _bounty0xToken, Bounty0xPresaleI _deployedPresaleContract)
        BntyExchangeRateCalculator(MICRO_DOLLARS_PER_BNTY_PRESALE, FIXED_PRESALE_USD_ETHER_PRICE)
        public
    {
        bounty0xToken = _bounty0xToken;
        deployedPresaleContract = _deployedPresaleContract;
    }

    event OnPreSaleBuyerCompensated(address indexed contributor, uint numTokens);

    /**
     * Compensate the presale investors at the addresses provider based on their contributions during the presale
     */
    function compensatePreSaleInvestors(address[] preSaleInvestors) public {
        // iterate through each investor
        for (uint i = 0; i < preSaleInvestors.length; i++) {
            address investorAddress = preSaleInvestors[i];

            // the deployed presale contract tracked the balance of each contributor
            uint weiContributed = deployedPresaleContract.balanceOf(investorAddress);

            // they contributed and haven't been paid
            if (weiContributed > 0 && tokensPaid[investorAddress] == 0) {
                // the amount of BNTY to award is the wei contributed divided by the fixed rate of WEI per BNTY
                uint numTokens = weiToBnty(weiContributed);

                // we can possibly run out of BNTY if every presale investor collects due to loss of precision with
                // integer division
                uint tokensToPay = Math.min256(bounty0xToken.balanceOf(this), numTokens);

                // mark them paid first
                tokensPaid[investorAddress] = tokensToPay;

                // transfer tokens to presale contributor address
                bounty0xToken.transfer(investorAddress, tokensToPay);

                // log the event
                OnPreSaleBuyerCompensated(investorAddress, tokensToPay);
            }
        }
    }
}
