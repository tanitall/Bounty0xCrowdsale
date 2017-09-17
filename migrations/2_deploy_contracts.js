var Bounty0xToken = artifacts.require("./Bounty0xToken.sol");
var Bounty0xContribution = artifacts.require("./Bounty0xContribution.sol");

module.exports = function(deployer) {
  deployer.deploy(Bounty0xToken);
  deployer.deploy(Bounty0xContribution);
};
