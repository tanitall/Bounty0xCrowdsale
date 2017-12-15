const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const Math = artifacts.require('zeppelin-solidity/contracts/math/Math.sol');
const SafeMath = artifacts.require('zeppelin-solidity/contracts/math/SafeMath.sol');
const { PRESALE_CONTRACT_ADDRESS } = require('./util/constants');

module.exports = function (deployer) {
  deployer.deploy(Math);
  deployer.deploy(SafeMath);
  deployer.link(Math, Bounty0xPresaleDistributor);
  deployer.link(SafeMath, Bounty0xPresaleDistributor);
  deployer.deploy(Bounty0xPresaleDistributor, Bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);
};