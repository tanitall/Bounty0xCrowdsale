require('babel-register');
require('babel-polyfill');

const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
  networks: {
    mainnet: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://mainnet.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 1
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC_ROPSTEN, 'https://ropsten.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 2
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC_RINKEBY, 'https://rinkeby.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 3
    },
    ganache: {
      provider: function () {
        return new HDWalletProvider(process.env.MNEMONIC_GANACHE, 'http://127.0.0.1:7545');
      },
      network_id: 5777
    },
    solc: {
      optimizer: {
        enabled: false,
        runs: 500
      }
    }
  }
};