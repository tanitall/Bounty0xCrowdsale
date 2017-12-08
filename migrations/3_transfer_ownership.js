const { BOUNTY0X_WALLET } = require('./constants');

const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');

module.exports = function (deployer, network, accounts) {
  deployer.then(
    async () => {
      // transfer crowdsale ownership to bounty0x wallet
      const bounty0xCrowdsale = await Bounty0xCrowdsale.deployed();
      await bounty0xCrowdsale.transferOwnership(BOUNTY0X_WALLET);


      // transfer crowdsale token controller ownership to bounty0x wallet
      const crowdsaleTokenController = await CrowdsaleTokenController.deployed();
      await crowdsaleTokenController.transferOwnership(BOUNTY0X_WALLET);
    }
  );
};
