pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import './Bounty0xToken.sol';
import './BntyExchangeRateCalculator.sol';
import './KnowsConstants.sol';
import './KnowsTime.sol';
import './AddressWhitelist.sol';
import './Bounty0xPresaleDistributor.sol';
import './Bounty0xReserveHolder.sol';

contract Bounty0xCrowdsale is KnowsTime, KnowsConstants, Ownable, BntyExchangeRateCalculator, AddressWhitelist, Pausable {
    using SafeMath for uint;

    // Crowdsale contracts
    Bounty0xToken public bounty0xToken;                                 // Reward tokens to compensate in

    // Contribution amounts
    mapping (address => uint) public contributionAmounts;            // The amount that each address has contributed
    uint public totalContributions;                                  // Total contributions given

    // Events
    event OnContribution(address indexed contributor, bool indexed duringWhitelistPeriod, uint indexed contributedWei, uint bntyAwarded);

    event OnWithdraw(address to, uint amount);

    function Bounty0xCrowdsale(Bounty0xToken _bounty0xToken, uint _USDEtherPrice)
    BntyExchangeRateCalculator(MICRO_DOLLARS_PER_BNTY_MAINSALE, _USDEtherPrice, SALE_START_DATE)
        public
    {
        bounty0xToken = _bounty0xToken;
    }

    // the crowdsale owner may withdraw any amount of ether from this contract at any time
    function withdraw(uint amount) public onlyOwner {
        msg.sender.transfer(amount);
        OnWithdraw(msg.sender, amount);
    }

    // All contributions come through the fallback function
    function () payable public whenNotPaused {
        // get the current time
        uint time = currentTime();

        // require the sale has started
        require(time >= SALE_START_DATE);

        // require that the sale has not ended
        require(time < SALE_END_DATE);

        // require we are not at the cap
        require(totalContributions.add(msg.value) <= usdToWei(HARD_CAP_AMOUNT_USD));

        // require that it's more than the minimum contribution amount
        require(msg.value >= usdToWei(MINIMUM_PARTICIPATION_AMOUNT_USD));

        bool isDuringWhitelistPeriod = time < WHITELIST_END_DATE;

        // these limits are only checked for the first N hours
        if (time < LIMITS_END_DATE) {
            // require that they paid a high gas price
            require(tx.gasprice <= MAX_GAS_PRICE);

            // require that they haven't sent too much gas
            require(msg.gas <= MAX_GAS);

            // if we are in the presale, we need to make sure the sender is on the whitelist
            if (isDuringWhitelistPeriod) {
                require(isWhitelisted(msg.sender));
                // also they must adhere to the maximum of $1.5k
                require(contributionAmounts[msg.sender].add(msg.value) < usdToWei(MAXIMUM_CONTRIBUTION_AMOUNT_USD_DURING_WHITELIST));
            } else {
                // otherwise they adhere to the public maximum of $10k
                require(contributionAmounts[msg.sender].add(msg.value) < usdToWei(MAXIMUM_CONTRIBUTION_AMOUNT_USD_POST_WHITELIST));
            }
        }

        // account contribution towards total
        totalContributions = totalContributions.add(msg.value);

        // account contribution towards address total
        contributionAmounts[msg.sender] = contributionAmounts[msg.sender].add(msg.value);

        // and send them some bnty
        uint amountBntyRewarded = weiToBnty(msg.value);
        require(bounty0xToken.transfer(msg.sender, amountBntyRewarded));

        // log the contribution
        OnContribution(msg.sender, isDuringWhitelistPeriod, msg.value, amountBntyRewarded);
    }
}