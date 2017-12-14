const Bounty0xToken = artifacts.require('Bounty0xToken');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const { PRESALE_POOL, PRESALE_CONTRACT_ADDRESS } = require('./util/constants');
const generateBNTY = require('./util/generateBNTY');

module.exports = function (deployer) {
  deployer.then(async () => {
    const bounty0xToken = await Bounty0xToken.deployed();

    // deploy the presale distributor contract
    await deployer.deploy(Bounty0xPresaleDistributor, bounty0xToken.address, PRESALE_CONTRACT_ADDRESS);
    const bounty0xPresaleDistributor = await Bounty0xPresaleDistributor.deployed();

    // fund it with presale tokens
    await generateBNTY(bounty0xToken, bounty0xPresaleDistributor, PRESALE_POOL);
  });
};
