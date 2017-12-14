const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');

module.exports = function (deployer) {
  deployer.then(
    async () => {
      const bounty0xToken = await Bounty0xToken.deployed();

      // deploy the token controller
      await deployer.deploy(CrowdsaleTokenController, bounty0xToken.address);
      const crowdsaleTokenController = await CrowdsaleTokenController.deployed();

      // transfer the bounty0x token ownership to the crowdsale contract
      const setControllerTx = await bounty0xToken.changeController(crowdsaleTokenController.address);

      // whitelist the distributors to be able to sent bounty0x
      const whitelistDistributorContractsTx = await crowdsaleTokenController.addToWhitelist([
        Bounty0xCrowdsale.address,
        Bounty0xPresaleDistributor.address
      ]);

      // turn on token transfers
      const enableTransfersTx = await crowdsaleTokenController.enableTransfers(true);
    }
  );
};

