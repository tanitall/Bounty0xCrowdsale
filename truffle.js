require('babel-register');
require('babel-polyfill');

const web3 = require('web3');
const HDWalletProvider = require('truffle-hdwallet-provider');

const EIGHT_GWEI = 8 * Math.pow(10, 9);

module.exports = {
  networks: {
    mainnet: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://mainnet.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 1,
      gasPrice: EIGHT_GWEI
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC_ROPSTEN, 'https://ropsten.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 2,
      gasPrice: EIGHT_GWEI
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC_RINKEBY, 'https://rinkeby.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 3,
      gasPrice: EIGHT_GWEI
    },
    ganache: {
      provider: function () {
        return new web3.providers.HttpProvider('http://127.0.0.1:7545');
      },
      network_id: 5777,
      gasPrice: EIGHT_GWEI
    },
    solc: {
      optimizer: {
        enabled: false,
        runs: 500
      }
    }
  }
};