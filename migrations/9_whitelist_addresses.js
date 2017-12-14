const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

const VALID_WHITELIST_ADDRESSES = require('./util/whitelistedAddresses.json')
  .filter(web3.isAddress);

module.exports = function (deployer) {
  deployer.then(
    async () => {
      // whitelist all the addresses on the whitelist with chunks of 100
      const bounty0xCrowdsale = await Bounty0xCrowdsale.deployed();

      // send a transaction for each 100 addresses
      for (let i = 0; i < VALID_WHITELIST_ADDRESSES.length; i += 100) {
        await bounty0xCrowdsale.addToWhitelist(VALID_WHITELIST_ADDRESSES.slice(i, i + 100));
      }
    }
  );
};
