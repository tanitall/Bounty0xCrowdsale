const PLACEHOLDER_WALLET = '0x0000000000000000000000000000000000000001';

//////// THESE CONSTANTS SHOULD BE TRIPLE CHECKED /////////////

export const TEAM_MEMBERS = [
  // FOUNDERS (total 150M)
  {
    name: 'Angelo',
    wallet: '0x694a9b63ff8956f9149a69fdb662436c5353af11',
    stake: 60 * Math.pow(10, 6), // 60M
    stakeDuration: 72
  },
  {
    name: 'Deniz',
    wallet: '0xbdfd4f31c55ccb866ab6ff9ed2863f1a4ceac8d6',
    stake: 45 * Math.pow(10, 6), // 45M
    stakeDuration: 72
  },
  {
    name: 'Pascal',
    wallet: '0x5a1ecbf485bfb23aa6e74393e9b26b40afd95da9',
    stake: 45 * Math.pow(10, 6), // 45M
    stakeDuration: 72
  },
  // ADVISERS (total 15M)
  {
    name: 'Ben',
    wallet: PLACEHOLDER_WALLET,
    stake: 3.23232323 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'Sean (pt. 1)',
    wallet: PLACEHOLDER_WALLET,
    stake: 2.020202 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'Sean (pt. 2)',
    wallet: PLACEHOLDER_WALLET,
    stake: 2.35690236 * Math.pow(10, 6),
    stakeDuration: 0
  },
  {
    name: 'Sean (optional)',
    wallet: PLACEHOLDER_WALLET,
    stake: 1.01010101 * Math.pow(10, 6),
    stakeDuration: 0
  },
  {
    name: 'Uwe (investment)',
    wallet: PLACEHOLDER_WALLET,
    stake: 1.21212121 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'Angelo (investment)',
    wallet: '0x694a9b63ff8956f9149a69fdb662436c5353af11',
    stake: 3.53198653 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'Cathy (investment)',
    wallet: PLACEHOLDER_WALLET,
    stake: 0.60606060 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'Ben (investment)',
    wallet: PLACEHOLDER_WALLET,
    stake: 0.36363636 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'Uwe (investment)',
    wallet: PLACEHOLDER_WALLET,
    stake: 0.30303030 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    name: 'George (investment)',
    wallet: PLACEHOLDER_WALLET,
    stake: 0.36363636 * Math.pow(10, 6),
    stakeDuration: 24
  }
];

export const BOUNTY0X_WALLET = '0x1c175d339e00e99daccb0cd14c50bf1bc4348ce8';

export const PRESALE_CONTRACT_ADDRESS = '0x998C31DBAD9567Df0DDDA990C0Df620B79F559ea';

export const FIXED_CROWDSALE_USD_ETHER_PRICE = 450;

// Token constants, in BNTY (a BNTY has 18 decimals)
export const MAXIMUM_TOKEN_SUPPLY = 500 * Math.pow(10, 6);                // maximum BNTY tokens to be minted at any given point
export const PRESALE_POOL = 18.95 * Math.pow(10, 6);                         // 18.95M BNTY Pre-Sale Pool
export const MAINSALE_POOL = 90.91 * Math.pow(10, 6);                        // 90.91M BNTY for Main-Sale Pool
export const BOUNTY0X_RESERVE = 225.14 * Math.pow(10, 6);                    // 225.14M BNTY Bounty0x Reserve Pool

//////// THESE CONSTANTS SHOULD BE TRIPLE CHECKED /////////////