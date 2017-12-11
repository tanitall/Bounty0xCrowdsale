require('babel-register');
require('babel-polyfill');

const HDWalletProvider = require('truffle-hdwallet-provider');
const mnemonic = 'TO BE FILLED PRIOR TO DEPLOYMENT';
const mnemonicRopsten = 'state couch illness ritual step rose west magnet arrange popular circle slam';
const mnemonicRinkeby = 'duty energy match scheme tape parade theory grow summer exchange enroll gate'
const mnemonicGanache = 'candy maple cake sugar pudding cream honey rich smooth crumble sweet treat';

module.exports = {
  networks: {
    mainnet: {
      provider: function () {
        return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 1
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(mnemonicRopsten, 'https://ropsten.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 2
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(mnemonicRinkeby, 'https://rinkeby.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 3
    },
    ganache: {
      provider: function () {
        return new HDWalletProvider(mnemonicGanache, 'http://127.0.0.1:7545');
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