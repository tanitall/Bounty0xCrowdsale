pragma solidity ^0.4.18;

// These are the specifications of the contract, unlikely to change
contract KnowsConstants {
    // The fixed USD price per BNTY
    uint public constant FIXED_PRESALE_USD_ETHER_PRICE = 355;
    uint public constant MICRO_DOLLARS_PER_BNTY_MAINSALE = 16500;
    uint public constant MICRO_DOLLARS_PER_BNTY_PRESALE = 13200;

    // Contribution constants
    uint public constant HARD_CAP_USD = 1500000;                           // in USD the maximum total collected amount
    uint public constant MAXIMUM_CONTRIBUTION_WHITELIST_PERIOD_USD = 1500; // in USD the maximum contribution amount during the whitelist period
    uint public constant MAXIMUM_CONTRIBUTION_LIMITED_PERIOD_USD = 10000;  // in USD the maximum contribution amount after the whitelist period ends
    uint public constant MAX_GAS_PRICE = 30 * (10 ** 9);                          // Max gas price of 30 gwei
    uint public constant MAX_GAS = 200000;                                        // Max gas that can be sent with tx

    // Time constants
    uint public constant SALE_START_DATE = 1513346400;                    // in unix timestamp Dec 15th @ 15:00 CET
    uint public constant WHITELIST_END_DATE = SALE_START_DATE + 24 hours; // End whitelist 24 hours after sale start date/time
    uint public constant LIMITS_END_DATE = SALE_START_DATE + 48 hours;    // End all limits 48 hours after the sale start date
    uint public constant SALE_END_DATE = SALE_START_DATE + 4 weeks;       // end sale in four weeks
    uint public constant VESTING_START_DATE = 1513771200;
    uint public constant UNFREEZE_DATE = SALE_START_DATE + 76 weeks;      // Bounty0x Reserve locked for 18 months

    function KnowsConstants() public {}
}
