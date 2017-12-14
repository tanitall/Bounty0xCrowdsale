const { FIXED_CROWDSALE_USD_ETHER_PRICE, MAINSALE_POOL } = require('./util/constants');
const generateBNTY = require('./util/generateBNTY');

const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');
const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');

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
      const bounty0xCrowdsale = await Bounty0xCrowdsale.deployed();

      // fund the crowdsale
      await generateBNTY(bounty0xToken, bounty0xCrowdsale, MAINSALE_POOL);
    }
  );
};
