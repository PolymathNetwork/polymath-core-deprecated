const PolyTokenMock = artifacts.require('../test/helpers/mockContracts/PolyTokenMock.sol');
const Compliance = artifacts.require('./Compliance.sol');
const Customers = artifacts.require('./Customers.sol');
const SecurityToken = artifacts.require('./SecurityToken.sol');
const SecurityTokenRegistrar = artifacts.require('./SecurityTokenRegistrar.sol');

module.exports = async (deployer, network) => {
  console.log(`Deploying Polymath Network Smart contracts to ${network}...`);
  await deployer.deploy(PolyTokenMock);
  await deployer.deploy(Customers, PolyTokenMock.address);
  await deployer.deploy(Compliance, Customers.address);
  await deployer.deploy(SecurityTokenRegistrar, PolyTokenMock.address, Customers.address, Compliance.address);
  console.log(`\nPolymath Network Smart Contracts Deployed:\n
    PolyToken: ${PolyTokenMock.address}\n
    Compliance: ${Compliance.address}\n
    Customers: ${Customers.address}\n
    SecurityTokenRegistrar: ${SecurityTokenRegistrar.address}\n
  `);
};
