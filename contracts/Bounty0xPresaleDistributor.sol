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
contract Bounty0xPresaleDistributor is KnowsConstants, BntyExchangeRateCalculator {
    using SafeMath for uint;

    Bounty0xPresaleI public deployedPresaleContract;
    Bounty0xToken public bounty0xToken;

    mapping(address => uint) public tokensPaid;

    function Bounty0xPresaleDistributor(Bounty0xToken _bounty0xToken, Bounty0xPresaleI _deployedPresaleContract)
        BntyExchangeRateCalculator(MICRO_DOLLARS_PER_BNTY_PRESALE, FIXED_PRESALE_USD_ETHER_PRICE, 0)
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
                // convert the amount of wei they contributed to the bnty
                uint bntyCompensation = Math.min256(weiToBnty(weiContributed), bounty0xToken.balanceOf(this));

                // mark them paid first
                tokensPaid[investorAddress] = bntyCompensation;

                // transfer tokens to presale contributor address
                require(bounty0xToken.transfer(investorAddress, bntyCompensation));

                // log the event
                OnPreSaleBuyerCompensated(investorAddress, bntyCompensation);
            }
        }
    }
}
