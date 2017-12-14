const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const { TEAM_MEMBERS } = require('./util/constants');
const generateBNTY = require('./util/generateBNTY');

module.exports = function (deployer) {
  // deploy the token vesting contracts
  for (let teamMember of TEAM_MEMBERS) {
    deployer.then(async () => {
      const bounty0xToken = await Bounty0xToken.deployed();

      const { wallet, stake, stakeDuration, name } = teamMember;

      console.log(`Deploying token vesting contract for ${name}...`);
      const tokenVesting = await Bounty0xTokenVesting.new(wallet, stakeDuration);
      console.log(`Deployed token vesting contract for ${name}: ${tokenVesting.address}`);

      await generateBNTY(bounty0xToken, tokenVesting, stake);
    });
  }
};
