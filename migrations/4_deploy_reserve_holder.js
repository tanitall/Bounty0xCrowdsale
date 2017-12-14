const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const { BOUNTY0X_WALLET, BOUNTY0X_RESERVE } = require('./util/constants');
const generateBNTY = require('./util/generateBNTY');

module.exports = function (deployer) {
  deployer.then(async () => {
    const bounty0xToken = await Bounty0xToken.deployed();

    // deploy the reserve holder contract
    await deployer.deploy(Bounty0xReserveHolder, bounty0xToken.address, BOUNTY0X_WALLET);
    const bounty0xReserveHolder = await Bounty0xReserveHolder.deployed();

    // fund it with the reserve tokens
    await generateBNTY(bounty0xToken, bounty0xReserveHolder, BOUNTY0X_RESERVE);
  });
};
