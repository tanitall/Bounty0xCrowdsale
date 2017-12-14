const Bounty0xToken = artifacts.require('Bounty0xToken');
const MiniMeTokenFactory = artifacts.require('MiniMeTokenFactory');

module.exports = function (deployer) {
  deployer.then(async () => {
    // create a new minime factory for the bounty0x token, which it uses to clone itself
    await deployer.deploy(MiniMeTokenFactory);

    // deploy the bounty0x token
    await deployer.deploy(Bounty0xToken, MiniMeTokenFactory.address);
  });
};
