pragma solidity ^0.4.18;

// These are the specifications of the contract, unlikely to change
contract KnowsConstants {
    // The fixed USD price per BNTY
    uint public constant MICRO_DOLLARS_PER_BNTY_MAINSALE = 16500;
    uint public constant MICRO_DOLLARS_PER_BNTY_PRESALE = 13200;

    // Contribution constants
    uint public constant MINIMUM_PARTICIPATION_AMOUNT_USD = 50;                   // in USD the minimum contribution per address
    uint public constant HARD_CAP_AMOUNT_USD = 1500000;                           // in USD the maximum total collected amount
    uint public constant MAXIMUM_CONTRIBUTION_AMOUNT_USD_DURING_WHITELIST = 1500; // in USD the maximum contribution amount during the whitelist period
    uint public constant MAXIMUM_CONTRIBUTION_AMOUNT_USD_POST_WHITELIST = 10000;  // in USD the maximum contribution amount after the whitelist period ends
    uint public constant MAX_GAS_PRICE = 30 * (10 ** 9);                          // Max gas price of 30 gwei

    // Time constants
    uint public constant SALE_START_DATE = 1513346400;                    // in unix timestamp Dec 15th @ 15:00 CET
    uint public constant WHITELIST_END_DATE = SALE_START_DATE + 24 hours; // End whitelist 24 hours after sale start date/time
    uint public constant SALE_END_DATE = SALE_START_DATE + 4 weeks;       // end sale in four weeks
    uint public constant UNFREEZE_DATE = SALE_START_DATE + 76 weeks;      // Bounty0x Reserve locked for 18 months

    // Token constants, in BNTY (a BNTY has 18 decimals)
    uint public constant MAXIMUM_TOKEN_SUPPLY = 500000000;                // maximum BNTY tokens to be minted at any given point
    uint public constant PRESALE_POOL = 18950000;                         // 18.95M BNTY Pre-Sale Pool
    uint public constant MAINSALE_POOL = 90900000;                        // 90.9M BNTY for Main-Sale Pool
    uint public constant FOUNDER1_STAKE = 60000000;                       // 60M BNTY
    uint public constant FOUNDER2_STAKE = 45000000;                       // 45M BNTY
    uint public constant FOUNDER3_STAKE = 45000000;                       // 45M BNTY
    uint public constant BOUNTY0X_RESERVE = 225150000;                    // 225.15M BNTY Bounty0x Reserve Pool
    uint public constant ADVISERS_POOL = 15000000;                        // 15M BNTY Advisers Pool

    // Vesting conditions
    uint public constant TEAM_VESTING_CLIFF = 0 weeks;                  // no cliff
    uint public constant TEAM_VESTING_PERIOD = 72 weeks;                // 18 month vesting period for founders
    uint public constant ADVISERS_VESTING_CLIFF = 0 weeks;              // no cliff
    uint public constant ADVISERS_VESTING_PERIOD = 24 weeks;            // 6 months vesting period for ADVISERS

    function KnowsConstants() public {}
}
