//////// THESE CONSTANTS SHOULD BE TRIPLE CHECKED /////////////

export const SALE_START_DATE = 1513346400; // in unix timestamp Dec 15th @ 15:00 CET

export const TEAM_MEMBERS = [
  // FOUNDERS (total 150M)
  {
    wallet: '0x60d7df77bcc92a0e92c6d2b7b4d276ad0dd33e90',
    stake: 60 * Math.pow(10, 6), // 60M
    stakeDuration: 72
  },
  {
    wallet: '0xd32ea3da0044fc5c9554a43bbbb3899c0124a9b5',
    stake: 45 * Math.pow(10, 6), // 45M
    stakeDuration: 72
  },
  {
    wallet: '0xb2427291cb661a2ed72c1e66a9fe2faffbb67b2f',
    stake: 45 * Math.pow(10, 6), // 45M
    stakeDuration: 72
  },
  // ADVISERS (total 150M)
  {
    wallet: '0x35e3fa8f6bdb38af7b657866ef39ebe43d9875c2',
    stake: 37.5 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    wallet: '0xd7383e030e7d277a000eb22fa3dede2ccacd9983',
    stake: 37.5 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    wallet: '0xf40c533cd70624b361d02884c46840cfb2e4f40c',
    stake: 37.5 * Math.pow(10, 6),
    stakeDuration: 24
  },
  {
    wallet: '0x264dfc4f90a58ed2e5be3fb5378e511c468f198f',
    stake: 37.5 * Math.pow(10, 6),
    stakeDuration: 24
  }
];

export const BOUNTY0X_WALLET = '0xc9afbf88b36a5c4a0a8a41918552e24a5c3a1958';

export const PRESALE_CONTRACT_ADDRESS = '0x998C31DBAD9567Df0DDDA990C0Df620B79F559ea';

export const FIXED_CROWDSALE_USD_ETHER_PRICE = 450;

// Token constants, in BNTY (a BNTY has 18 decimals)
export const MAXIMUM_TOKEN_SUPPLY = 500000000;                // maximum BNTY tokens to be minted at any given point
export const PRESALE_POOL = 18950000;                         // 18.95M BNTY Pre-Sale Pool
export const MAINSALE_POOL = 90900000;                        // 90.9M BNTY for Main-Sale Pool
export const BOUNTY0X_RESERVE = 225150000;                    // 225.15M BNTY Bounty0x Reserve Pool

//////// THESE CONSTANTS SHOULD BE TRIPLE CHECKED /////////////