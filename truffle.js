require('babel-register');
require('babel-polyfill');

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
      host: 'localhost',
      port: 8545,
      network_id: '*',
      // from: '0x00F13d5bCA2E8A4E58fD8018a7b1e8D286dD135A',
      gas: 4700036,
      gasPrice: 20000000000,
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

// Comment line below and uncomment the lines going after it to use Infura for deployment
module.exports = config;

// const HDWalletProvider = require('truffle-hdwallet-provider');
//
// const mnemonic = '';
// const infuraToken = ''; // https://infura.io/
//
// config.networks = {
//   ropsten: {
//     provider: function() {
//       return new HDWalletProvider(mnemonic, 'https://ropsten.infura.io/' + infuraToken)
//     },
//     network_id: config.networks.ropsten.network_id,
//     gas: config.networks.ropsten.gas,
//   }
// };
//
// module.exports = config;
