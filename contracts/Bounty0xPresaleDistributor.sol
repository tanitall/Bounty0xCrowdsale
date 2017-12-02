pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Bounty0xToken.sol';
import './interfaces/Bounty0xPresaleI.sol';

/*
This contract manages compensation of the presale investors, based on the contribution balances recorded in the presale
contract.
*/
contract Bounty0xPresaleDistributor is Ownable {
    using SafeMath for uint;

    // $355.00 USD/ETH / 0.0132 USD/BNTY == 26,893.9393939394 BNTY/ETH
    // 26,893.9393939394 BNTY/ETH * 10^-18 ETH/WEI * 10^18 BNTY/BNTYWEI == 26894 BNTYWEI/WEI
    uint256 public constant PRESALE_FIXED_RATE = 26880; // BNTYWEI / WEI
    // if we give all 705 ether out that's 705eth * 10^18 wei/eth * 26893 bntywei/wei * 10^-18 bnty/bntywei ==
    // 704.976614706013306171 * 26893 == 18,958,936.0992888
    // this contract's balance is 18.95 M so we must reduce the BNTY/WEI from 26894 to 26880 so every presale investor
    // is compensated at the exact same ratio
    // this is a reduction of 0.04% which does not change the price paid of the presale investors in USD

    Bounty0xPresaleI public deployedPresaleContract;
    Bounty0xToken public bounty0xToken;

    mapping(address => uint) public tokensPaid;

    function Bounty0xPresaleDistributor(Bounty0xToken _bounty0xToken, Bounty0xPresaleI _deployedPresaleContract) public {
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
                uint numTokens = weiContributed.mul(PRESALE_FIXED_RATE);

                // we shouldn't run out of presale tokens at the very end, but in case we do...
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
