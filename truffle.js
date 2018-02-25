require('babel-register');
require('babel-polyfill');
const WalletProvider = require("truffle-hdwallet-provider-privkey");
const privKey = require('fs').readFileSync('./infura_privKey').toString();
const apiKey = require('fs').readFileSync('./infura_apiKey').toString();

// const WalletProvider = require("truffle-wallet-provider");
// const keystore = require('fs').readFileSync('./sample-keystore').toString();
// const pass = require('fs').readFileSync('./sample-pass').toString();
// const wallet = require('ethereumjs-wallet').fromV3(keystore, pass);

const config = {
  networks: {
    development: {
      host: 'localhost',
      port: 8545,
      gas: 15e6,
      gasPrice: 0x01,
      network_id: '*',
    },
    ropsten: {
      provider: new WalletProvider(privKey, "https://ropsten.infura.io/"+ apiKey),
      network_id: 3,
      gas: 4700036,
      gasPrice: 130000000000,
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
  },
  mocha: {
    useColors: true,
    slow: 30000,
    bail: true,
  },
  dependencies: {},
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};

module.exports = config;
