const { BOUNTY0X_RESERVE, PRESALE_POOL, MAINSALE_POOL } = require('./util/constants');
const { VESTED_TOKEN_CONTRACTS } = require('./util/constants');

const fs = require('fs');
const path = require('path');
const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');
const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');

module.exports = function (deployer) {
  deployer.then(
    async () => {
      const vestedTokens = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../build/vested-tokens.json')));

      const bounty0xToken = await Bounty0xToken.deployed();
      const bounty0xCrowdsale = await Bounty0xCrowdsale.deployed();
      const bounty0xPresaleDistributor = await Bounty0xPresaleDistributor.deployed();
      const bounty0xReserveHolder = await Bounty0xReserveHolder.deployed();

      // fund the crowdsale
      await bounty0xToken.generateTokens(bounty0xCrowdsale.address, MAINSALE_POOL * Math.pow(10, 18));
      await bounty0xToken.generateTokens(bounty0xPresaleDistributor.address, PRESALE_POOL * Math.pow(10, 18));
      await bounty0xToken.generateTokens(bounty0xReserveHolder.address, BOUNTY0X_RESERVE * Math.pow(10, 18));

      for (let id in VESTED_TOKEN_CONTRACTS) {
        if (VESTED_TOKEN_CONTRACTS.hasOwnProperty(id)) {
          const { stake } = VESTED_TOKEN_CONTRACTS[id];
          const address = vestedTokens[id];

          console.log(`Generating ${stake} tokens for ${id} at address ${address}`);
          await bounty0xToken.generateTokens(address, stake * Math.pow(10, 18));
        }
      }
    }
  );
};
