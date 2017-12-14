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
      const bounty0xCrowdsale = await Bounty0xCrowdsale.deployed();
      const bounty0xPresaleDistributor = await Bounty0xPresaleDistributor.deployed();

      // deploy the token controller
      await deployer.deploy(CrowdsaleTokenController, bounty0xToken.address);
      const crowdsaleTokenController = await CrowdsaleTokenController.deployed();

      // transfer the bounty0x token ownership to the crowdsale contract
      const setControllerTx = await bounty0xToken.changeController(crowdsaleTokenController.address);

      // whitelist the distributors to be able to sent bounty0x
      const whitelistDistributorContractsTx = await crowdsaleTokenController.addToWhitelist([
        bounty0xCrowdsale.address,
        bounty0xPresaleDistributor.address
      ]);

      // turn on token transfers
      const enableTransfersTx = await crowdsaleTokenController.enableTransfers(true);
    }
  );
};

