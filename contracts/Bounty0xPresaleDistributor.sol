pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './Bounty0xToken.sol';
import './interfaces/Bounty0xPresaleI.sol';

/*
This contract manages compensation of the presale investors, based on the contribution balances recorded in the presale
contract.
*/
contract Bounty0xPresaleDistributor {
    using SafeMath for uint;

    uint256 public constant PRESALE_FIXED_RATE = 27725850154382;      // WEI per BNTY

    Bounty0xPresaleI public deployedPresaleContract;
    Bounty0xToken public bounty0xToken;

    mapping(address => bool) public tokensPaid;

    function Bounty0xPresaleDistributor(Bounty0xToken _bounty0xToken, Bounty0xPresaleI _deployedPresaleContract) public {
        bounty0xToken = _bounty0xToken;
        deployedPresaleContract = _deployedPresaleContract;
    }

    event OnPreSaleBuyerCompensated(address indexed contributor, uint numTokens);

    // anyone can call this to distribute tokens to the presale investors
    function compensatePreSaleInvestors(address[] preSaleInvestors) public {
        for (uint i = 0; i < preSaleInvestors.length; i++) {
            address investorAddress = preSaleInvestors[i];

            // the deployed presale contract tracked the balance of each contributor
            uint weiContributed = deployedPresaleContract.balanceOf(investorAddress);

            // they contributed and haven't been paid
            if (weiContributed > 0 && !tokensPaid[investorAddress]) {
                // the amount of BNTY to award is the wei contributed divided by the fixed rate of WEI per BNTY
                uint numTokens = weiContributed.div(PRESALE_FIXED_RATE);

                // mark them paid first
                tokensPaid[investorAddress] = true;

                // transfer tokens to presale contributor address
                bounty0xToken.transfer(investorAddress, numTokens);

                // log the event
                OnPreSaleBuyerCompensated(investorAddress, numTokens);
            }
        }
    }
}
