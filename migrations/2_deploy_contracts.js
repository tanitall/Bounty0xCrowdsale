const { BOUNTY0X_RESERVE, BOUNTY0X_WALLET, PRESALE_CONTRACT_ADDRESS, FIXED_CROWDSALE_USD_ETHER_PRICE, TEAM_MEMBERS, PRESALE_POOL, MAINSALE_POOL } = require('./constants');

const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const MiniMeTokenFactory = artifacts.require('MiniMeTokenFactory');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');
const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');

module.exports = function (deployer, network, accounts) {
  // Helper function that deploys a contract via deployer and returns the deployed instance
  const deploy = (Contract, ...args) => deployer.deploy(Contract, ...args)
    .then(() => Contract.deployed());

  async function printTotalSupply(bounty0xToken) {
    const totalSupply = await bounty0xToken.totalSupply();
    console.log('TOTAL SUPPLY: ' + totalSupply.toString());
  }

  deployer.then(
    async () => {
      // create a new minime factory for the bounty0x token, which it uses to clone itself
      const miniMeTokenFactory = await deploy(MiniMeTokenFactory);

      // deploy the bounty0x token
      const bounty0xToken = await deploy(Bounty0xToken, miniMeTokenFactory.address);


      // deploy the presale distributor contract
      const bounty0xPresaleDistributor = await deploy(Bounty0xPresaleDistributor, bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);
      // fund it with presale tokens
      const fundPresaleDistributorTx = await bounty0xToken.generateTokens(bounty0xPresaleDistributor.address, PRESALE_POOL * Math.pow(10, 18));


      // deploy the reserve holder contract
      const bounty0xReserveHolder = await deploy(Bounty0xReserveHolder, bounty0xToken.address, BOUNTY0X_WALLET);
      // fund it with the reserve tokens
      const fundReserveHolderTx = await bounty0xToken.generateTokens(bounty0xReserveHolder.address, BOUNTY0X_RESERVE * Math.pow(10, 18));

      // deploy the token vesting contracts
      for (let teamMember of TEAM_MEMBERS) {
        const { wallet, stake, stakeDuration } = teamMember;
        const tokenVesting = await deploy(Bounty0xTokenVesting, wallet, stakeDuration);
        const fundVestingTx = await bounty0xToken.generateTokens(stake * Math.pow(10, 18), tokenVesting.address);
      }

      // deploy the crowdsale contract with its constants
      const bounty0xCrowdsale = await deploy(
        Bounty0xCrowdsale,
        bounty0xToken.address,
        FIXED_CROWDSALE_USD_ETHER_PRICE
      );
      // fund the crowdsale
      const fundCrowdsaleTx = await bounty0xToken.generateTokens(MAINSALE_POOL * Math.pow(10, 18), bounty0xCrowdsale.address);

      // deploy the token controller
      const crowdsaleTokenController = await deploy(CrowdsaleTokenController, bounty0xToken.address);


      // transfer the bounty0x token ownership to the crowdsale contract
      const setControllerTx = await bounty0xToken.changeController(crowdsaleTokenController.address);

      // whitelist the distributors to be able to sent bounty0x
      const whitelistDistributorContractsTx = await crowdsaleTokenController.addToWhitelist([
        bounty0xCrowdsale.address,
        bounty0xPresaleDistributor.address
      ]);

    }
  );
};
