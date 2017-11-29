require('babel-register');
require('babel-polyfill');

const HDWalletProvider = require('truffle-hdwallet-provider');
const mnemonic = 'state couch illness ritual step rose west magnet arrange popular circle slam';

module.exports = {
  networks: {
    ropsten: {
      provider: function () {
        return new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/3aPdTSUEXEXeffefJPDb');
      },
      network_id: 3
    }
  }
};
