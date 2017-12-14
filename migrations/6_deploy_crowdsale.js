const { FIXED_CROWDSALE_USD_ETHER_PRICE } = require('./util/constants');
const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

module.exports = function (deployer) {
  deployer.then(
    async () => {
      const bounty0xToken = await Bounty0xToken.deployed();

      // deploy the crowdsale contract with its constants
      await deployer.deploy(
        Bounty0xCrowdsale,
        bounty0xToken.address,
        FIXED_CROWDSALE_USD_ETHER_PRICE
      );
    }
  );
};
