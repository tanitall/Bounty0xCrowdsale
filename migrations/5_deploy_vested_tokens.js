const { VESTED_TOKEN_CONTRACTS } = require('./util/constants');
const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');
const Bounty0xPresaleDistributor = artifacts.require('Bounty0xPresaleDistributor');
const fs = require('fs');
const path = require('path');

module.exports = function (deployer, network) {
  // deploy the token vesting contracts and save the results to a file (workaround so we can share the information between contracts)
  deployer.then(async () => {
    const vestedTokensPath = path.resolve(__dirname, '../build/vested-tokens.json');
    const exists = fs.existsSync(vestedTokensPath);
    const vestingContracts = exists ? JSON.parse(fs.readFileSync(vestedTokensPath)) : { [network]: {} };

    for (let id in VESTED_TOKEN_CONTRACTS) {
      if (VESTED_TOKEN_CONTRACTS.hasOwnProperty(id)) {
        const { wallet, stakeDuration } = VESTED_TOKEN_CONTRACTS[id];

        console.log(`Deploying token vesting contract for ${id}...`);
        const tokenVesting = await Bounty0xTokenVesting.new(wallet, stakeDuration);
        console.log(`Deployed token vesting contract for ${id}: ${tokenVesting.address}`);

        vestingContracts[network][id] = tokenVesting.address;
      }
    }

    // export out the addresses to a file
    if (!fs.existsSync(path.resolve(__dirname, '../build'))) {
      fs.mkdirSync(path.resolve(__dirname, '../build'));
    }

    fs.writeFileSync(vestedTokensPath, JSON.stringify(vestingContracts));
  });
};
