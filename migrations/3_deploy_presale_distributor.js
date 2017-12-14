const Bounty0xToken = artifacts.require('Bounty0xToken');
const MiniMeTokenFactory = artifacts.require('MiniMeTokenFactory');
const generateBNTY = require('./util/generateBNTY');

module.exports = function (deployer) {
  deployer.then(async () => {
    const bounty0xToken = await Bounty0xToken.deployed();

    // deploy the presale distributor contract
    const bounty0xPresaleDistributor = await deployer.deploy(Bounty0xPresaleDistributor, bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);

    // fund it with presale tokens
    await generateBNTY(bounty0xToken, bounty0xPresaleDistributor, PRESALE_POOL);
  });
};
