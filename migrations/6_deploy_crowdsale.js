const { FIXED_CROWDSALE_USD_ETHER_PRICE } = require('./util/constants');
const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');

module.exports = function (deployer) {
  deployer.deploy(
    Bounty0xCrowdsale,
    Bounty0xToken.address,
    FIXED_CROWDSALE_USD_ETHER_PRICE
  );
};
