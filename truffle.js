require('babel-register');
require('babel-polyfill');

module.exports = {
  networks: {
    local: {
      host: "localhost",
      port: 8545,
      network_id: "*"
    },
    ropsten: {
      host: "localhost",
      port: 1337,
      network_id: "3",
      from: '0xb571be0e1876dc43345cfb08e1ad2792f678aefd',
      gas: 4612388
    }
  },
  mocha: {
    useColors: true,
    slow: 30000,
    bail: true
  },
  dependencies: {
  }
};
