const Bounty0xTokenVesting = artifacts.require('Bounty0xTokenVesting');
const Bounty0xToken = artifacts.require('Bounty0xToken');

const fs = require('fs');
const path = require('path');

const vestedTokensPath = path.resolve(__dirname, '../build/vested-tokens.json');

module.exports = function (deployer, network) {
  if (network !== 'mainnet') {
    return;
  }

  function readFile() {
    const exists = fs.existsSync(vestedTokensPath);
    const file = exists ? JSON.parse(fs.readFileSync(vestedTokensPath)) : {};
    file[ network ] = file[ network ] || {};
    return file;
  }

  deployer.then(
    async () => {
      const VESTING = readFile();

      const vestingForNetwork = VESTING[network];

      for (let user in vestingForNetwork) {
        if (vestingForNetwork.hasOwnProperty(user)) {
          const bxtv = await Bounty0xTokenVesting.at(vestingForNetwork[user]);
          const releasableAmount = await bxtv.releasableAmount(Bounty0xToken.address);

          if (releasableAmount.valueOf() !== '0') {
            await bxtv.release(Bounty0xToken.address);
          }
        }
      }
    }
  );
};
