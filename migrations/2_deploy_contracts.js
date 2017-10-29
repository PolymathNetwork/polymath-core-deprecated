const SafeMath = artifacts.require('./SafeMath.sol');
const Ownable = artifacts.require('./Ownable.sol');
const ERC20 = artifacts.require('./ERC20.sol');
var PolyToken = artifacts.require('./PolyToken.sol');
var SecurityToken = artifacts.require('./SecurityToken.sol');
var Compliance = artifacts.require('./Compliance.sol');
var Customers = artifacts.require('./Customers.sol');
var SecurityTokens = artifacts.require('./SecurityTokens.sol');

module.exports = (deployer) => {
  deployer.deploy(PolyToken);
  deployer.deploy(SecurityToken);
  deployer.deploy(Compliance);
  deployer.deploy(Customers);
  deployer.deploy(SecurityTokens);
};
