const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const { PRESALE_CONTRACT_ADDRESS } = require('./util/constants');

module.exports = function (deployer) {
  deployer.then(async () => {
    const bounty0xToken = await Bounty0xToken.deployed();

    // deploy the presale distributor contract
    await deployer.deploy(Bounty0xPresaleDistributor, bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);
  });
};
