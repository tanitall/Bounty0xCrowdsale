var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "state couch illness ritual step rose west magnet arrange popular circle slam";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/3aPdTSUEXEXeffefJPDb");
      },
      network_id: 3
    }
  }
};
