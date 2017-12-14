const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const { BOUNTY0X_WALLET } = require('./util/constants');

module.exports = function (deployer) {
  deployer.deploy(Bounty0xReserveHolder, Bounty0xToken.address, BOUNTY0X_WALLET);
};
