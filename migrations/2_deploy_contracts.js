var Bounty0xToken = artifacts.require("./Bounty0xToken.sol");
var Bounty0xContribution = artifacts.require("./Bounty0xContribution.sol");

module.exports = function(deployer) {
  const founder1 = '0x9d6eb7e4a9dd3e9edbc3be1483b34be9b68716f4';
  const foudner2 = '0x92d01f119132f39fba9e11dc1048af3ff0d856aa';
  const founder3 = '0xae439b21043c5f927160a0eebc20dfab845d0596';
  const bounty0xWallet = '0x9d6eb7e4a9dd3e9edbc3be1483b34be9b68716f4';
  const advisers = ['0x9d6eb7e4a9dd3e9edbc3be1483b34be9b68716f4', '0xbf8635365f8176094d8297bc33c7bb679a9029c5',
  '0xae439b21043c5f927160a0eebc20dfab845d0596', '0x92d01f119132f39fba9e11dc1048af3ff0d856aa'];

  const preSaleInvestors = ['0x9d6eb7e4a9dd3e9edbc3be1483b34be9b68716f4', '0xbf8635365f8176094d8297bc33c7bb679a9029c5',
  '0xae439b21043c5f927160a0eebc20dfab845d0596', '0x92d01f119132f39fba9e11dc1048af3ff0d856aa'];

  const whitelistArray = ['0x9d6eb7e4a9dd3e9edbc3be1483b34be9b68716f4', '0xbf8635365f8176094d8297bc33c7bb679a9029c5',
  '0xae439b21043c5f927160a0eebc20dfab845d0596', '0x92d01f119132f39fba9e11dc1048af3ff0d856aa'];
  deployer.deploy(Bounty0xToken);
  deployer.deploy(Bounty0xContribution, founder1, foudner2, founder3, bounty0xWallet, preSaleInvestors, whitelistArray);
};
