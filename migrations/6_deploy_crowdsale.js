const { FIXED_CROWDSALE_USD_ETHER_PRICE } = require('./util/constants');
const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Math = artifacts.require('zeppelin-solidity/contracts/math/Math.sol');
const SafeMath = artifacts.require('zeppelin-solidity/contracts/math/SafeMath.sol');

module.exports = function (deployer) {
  deployer.link(Math, Bounty0xCrowdsale);
  deployer.link(SafeMath, Bounty0xCrowdsale);
  deployer.deploy(
    Bounty0xCrowdsale,
    Bounty0xToken.address,
    FIXED_CROWDSALE_USD_ETHER_PRICE
  );
};