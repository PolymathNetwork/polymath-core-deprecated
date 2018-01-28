const Compliance = artifacts.require('./Compliance.sol');
const Customers = artifacts.require('./Customers.sol');
const SecurityToken = artifacts.require('./SecurityToken.sol');
const SecurityTokenRegistrar = artifacts.require('./SecurityTokenRegistrar.sol');
const PolyToken = '0x96a62428509002a7ae5f6ad29e4750d852a3f3d7';

module.exports = async (deployer, network) => {
  console.log(`Deploying Polymath Network Smart contracts to ${network}...`);
  try{
    await deployer.deploy(Customers, PolyToken);
    await deployer.deploy(Compliance, Customers.address);
    await deployer.deploy(SecurityTokenRegistrar, PolyToken, Customers.address, Compliance.address);
    console.log(`\nPolymath Network Smart Contracts Deployed:\n
      PolyToken: ${PolyToken}\n
      Compliance: ${Compliance.address}\n
      Customers: ${Customers.address}\n
      SecurityTokenRegistrar: ${SecurityTokenRegistrar.address}\n
    `);
  } catch(err) {
    console.log('Deploy error', err);
  }
};
