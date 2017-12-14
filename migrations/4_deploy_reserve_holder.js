const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const { BOUNTY0X_WALLET } = require('./util/constants');

module.exports = function (deployer) {
  deployer.then(async () => {
    const bounty0xToken = await Bounty0xToken.deployed();

    // deploy the reserve holder contract
    await deployer.deploy(Bounty0xReserveHolder, bounty0xToken.address, BOUNTY0X_WALLET);
  });
};
