const Compliance = artifacts.require('./Compliance.sol');
const Customers = artifacts.require('./Customers.sol');
const SecurityToken = artifacts.require('./SecurityToken.sol');
const SecurityTokenRegistrar = artifacts.require('./SecurityTokenRegistrar.sol');
const NameSpaceRegistrar = artifacts.require('./NameSpaceRegistrar.sol');
const SimpleCappedOfferingFactory = artifacts.require('./SimpleCappedOfferingFactory.sol');
//NB - these are Ropsten addresses
const PolyToken = '0x96a62428509002a7ae5f6ad29e4750d852a3f3d7';
const PolyFeeAddress = '0x627306090abaB3A6e1400e9345bC60c78a8BEf57';
const Fee = 100000*10**18;

module.exports = async (deployer, network) => {
  console.log(`Deploying Polymath Network Smart contracts to ${network}...`);
  try{
    await deployer.deploy(Customers, PolyToken);
    await deployer.deploy(Compliance, Customers.address);
    await deployer.deploy(NameSpaceRegistrar);
    await deployer.deploy(SecurityTokenRegistrar, PolyToken, Customers.address, Compliance.address, NameSpaceRegistrar.address);
    let compliance = await Compliance.deployed()
    await compliance.setRegistrarAddress(SecurityTokenRegistrar.address);
    console.log(`\nPolymath Network Smart Contracts Deployed:\n
      PolyToken: ${PolyToken}\n
      Compliance: ${Compliance.address}\n
      Customers: ${Customers.address}\n
      SecurityTokenRegistrar: ${SecurityTokenRegistrar.address}\n
      NameSpaceRegistrar: ${NameSpaceRegistrar.address}\n
    `);
  } catch(err) {
    console.log('Deploy error', err);
  }
};

//
// Uncomment the lines below to deploy an offering factory with a developer account
//

// module.exports = async (deployer, network) => {
//   console.log(`Deploying Offering Factory to ${network}...`);
//   try{
//     await deployer.deploy(SimpleCappedOfferingFactory);
//     console.log(`\nPolymath Network Smart Contracts Deployed:\n
//       Offering Factory: ${SimpleCappedOfferingFactory.address}\n
//     `);
//   } catch(err) {
//     console.log('Deploy error', err);
//   }
// };
