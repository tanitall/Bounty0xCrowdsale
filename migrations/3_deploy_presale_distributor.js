const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const { PRESALE_CONTRACT_ADDRESS } = require('./util/constants');

module.exports = function (deployer) {
  deployer.deploy(Bounty0xPresaleDistributor, Bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);
};
