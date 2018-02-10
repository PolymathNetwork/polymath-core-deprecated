require('babel-register');
require('babel-polyfill');
const WalletProvider = require("truffle-wallet-provider");
const keystore = require('fs').readFileSync('./UTC--2018-01-26T17-50-04Z--074bf411-7666-c662-f1a0-d6a93f5d8719').toString();
const pass = require('fs').readFileSync('./password1.txt').toString();
const wallet = require('ethereumjs-wallet').fromV3(keystore, pass);

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
      provider: new WalletProvider(wallet, "https://ropsten.infura.io/"),
      network_id: 3,
      gas: 4.5e6,
      gasPrice: 0x50,
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
