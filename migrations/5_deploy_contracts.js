const { BOUNTY0X_RESERVE, BOUNTY0X_WALLET, FIXED_CROWDSALE_USD_ETHER_PRICE, TEAM_MEMBERS, MAINSALE_POOL } = require('./util/constants');
const sleep = require('./util/sleep');
const generateBNTY = require('./util/generateBNTY');

const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');
const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');

module.exports = function (deployer, network) {
  const log = (...args) => network !== 'test' ? console.log(...args) : null;

  deployer.then(
    async () => {
      // deploy the reserve holder contract
      const bounty0xReserveHolder = await deployer.deploy(Bounty0xReserveHolder, bounty0xToken.address, BOUNTY0X_WALLET);
      // fund it with the reserve tokens
      await generateBNTY(bounty0xToken, bounty0xReserveHolder, BOUNTY0X_RESERVE);

      // deploy the token vesting contracts
      for (let teamMember of TEAM_MEMBERS) {
        const { wallet, stake, stakeDuration, name } = teamMember;

        log(`Deploying token vesting contract for ${name}...`);
        const tokenVesting = await Bounty0xTokenVesting.new(wallet, stakeDuration);
        log(`Deployed token vesting contract for ${name}: ${tokenVesting.address}`);

        await generateBNTY(bounty0xToken, tokenVesting, stake);
      }

      // deploy the crowdsale contract with its constants
      const bounty0xCrowdsale = await deployer.deploy(
        Bounty0xCrowdsale,
        bounty0xToken.address,
        FIXED_CROWDSALE_USD_ETHER_PRICE
      );

      // fund the crowdsale
      await generateBNTY(bounty0xToken, bounty0xCrowdsale, MAINSALE_POOL);

      // deploy the token controller
      const crowdsaleTokenController = await deployer.deploy(CrowdsaleTokenController, bounty0xToken.address);


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
