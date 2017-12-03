const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xCrowdsale = artifacts.require('Bounty0xCrowdsale');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const Bounty0xReserveHolder = artifacts.require('Bounty0xReserveHolder');
const MiniMeTokenFactory = artifacts.require('MiniMeTokenFactory');
const CrowdsaleTokenController = artifacts.require('CrowdsaleTokenController');

//////// THESE CONSTANTS SHOULD BE TRIPLE CHECKED /////////////
const FOUNDER_1 = '0x60d7df77bcc92a0e92c6d2b7b4d276ad0dd33e90';
const FOUNDER_2 = '0xd32ea3da0044fc5c9554a43bbbb3899c0124a9b5';
const FOUNDER_3 = '0xb2427291cb661a2ed72c1e66a9fe2faffbb67b2f';
const BOUNTY0X_WALLET = '0xc9afbf88b36a5c4a0a8a41918552e24a5c3a1958';

const ADVISERS = [
  '0x35e3fa8f6bdb38af7b657866ef39ebe43d9875c2',
  '0xd7383e030e7d277a000eb22fa3dede2ccacd9983',
  '0xf40c533cd70624b361d02884c46840cfb2e4f40c',
  '0x264dfc4f90a58ed2e5be3fb5378e511c468f198f'
];

const PRESALE_CONTRACT_ADDRESS = '0x998C31DBAD9567Df0DDDA990C0Df620B79F559ea';

const FIXED_CROWDSALE_USD_ETHER_PRICE = 450;
//////// THESE CONSTANTS SHOULD BE TRIPLE CHECKED /////////////

module.exports = function (deployer, network, accounts) {
  // helper function that deploys a contract via deployer and returns the deployed instance
  const deploy = (Contract, ...args) => deployer.deploy(Contract, ...args)
    .then(() => Contract.deployed());

  deployer.then(
    async () => {
      // create a new minime factory for the bounty0x token, which it uses to clone itself
      const miniMeTokenFactory = await deploy(MiniMeTokenFactory);

      // deploy the bounty0x token
      const bounty0xToken = await deploy(Bounty0xToken, miniMeTokenFactory.address);

      // deploy the token controller for the crowdsale
      const crowdsaleTokenController = await deploy(CrowdsaleTokenController, bounty0xToken.address);

      // deploy the presale distributor contract
      const bounty0xPresaleDistributor = await deploy(Bounty0xPresaleDistributor, bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);

      // deploy the reserve holder contract
      const bounty0xReserveHolder = await deploy(Bounty0xReserveHolder, bounty0xToken.address, BOUNTY0X_WALLET);

      // deploy the crowdsale contract with its constants
      const bounty0xCrowdsale = await deploy(
        Bounty0xCrowdsale,
        bounty0xToken.address,
        FIXED_CROWDSALE_USD_ETHER_PRICE,
        FOUNDER_1, FOUNDER_2, FOUNDER_3,
        BOUNTY0X_WALLET,
        ADVISERS,
        { gas: 6000000 }
      );

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
