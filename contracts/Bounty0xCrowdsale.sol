pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';

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
    event OnContribution(address indexed contributor, bool indexed duringWhitelistPeriod, uint indexed contributedWei, uint bntyAwarded, uint refundedWei);
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
        uint time = currentTime();

        // require the sale has started
        require(time >= SALE_START_DATE);

        // require that the sale has not ended
        require(time < SALE_END_DATE);

        // max contribution is AT MOST the hard cap USD, will be adjusted below
        uint maximumContribution = usdToWei(HARD_CAP_USD);

        // store whether the contribution is made during the whitelist period
        bool isDuringWhitelistPeriod = time < WHITELIST_END_DATE;

        // these limits are only checked during the limited period
        if (time < LIMITS_END_DATE) {
            // require that they have not overpaid their gas price
            require(tx.gasprice <= MAX_GAS_PRICE);

            // require that they haven't sent too much gas
            require(msg.gas <= MAX_GAS);

            // if we are in the WHITELIST period, we need to make sure the sender contributed to the presale
            if (isDuringWhitelistPeriod) {
                require(isWhitelisted(msg.sender));

                // the maximum contribution is set for the whitelist period
                maximumContribution = usdToWei(MAXIMUM_CONTRIBUTION_WHITELIST_PERIOD_USD);
            } else {
                // the maximum contribution is set for the limited period
                maximumContribution = usdToWei(MAXIMUM_CONTRIBUTION_LIMITED_PERIOD_USD);
            }
        }

        // the additional amount that this address may contribute
        uint addressMaximumContribution = maximumContribution.sub(contributionAmounts[msg.sender]);

        // how much to refund the sender
        uint refundWei = 0;
        uint contribution = msg.value;

        // sent too much
        if (msg.value > addressMaximumContribution) {
            contribution = addressMaximumContribution;
            refundWei = msg.value.sub(addressMaximumContribution);
        }

        // require that they are allowed to contribute more
        require(contribution > 0);

        // account contribution towards total
        totalContributions = totalContributions.add(contribution);

        // account contribution towards address total
        contributionAmounts[msg.sender] = contributionAmounts[msg.sender].add(contribution);

        // and send them some bnty
        uint amountBntyRewarded = Math.min256(weiToBnty(contribution), bounty0xToken.balanceOf(this));
        require(bounty0xToken.transfer(msg.sender, amountBntyRewarded));

        if (refundWei > 0) {
            msg.sender.transfer(refundWei);
        }

        // log the contribution
        OnContribution(msg.sender, isDuringWhitelistPeriod, contribution, amountBntyRewarded, refundWei);
    }
}