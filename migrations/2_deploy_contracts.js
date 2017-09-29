const SafeMath = artifacts.require('./SafeMath.sol');
const Ownable = artifacts.require('./Ownable.sol');
const ERC20 = artifacts.require('./ERC20.sol');
var SecurityToken = artifacts.require("./SecurityToken.sol");

module.exports = (deployer) => {
  deployer.deploy(SecurityToken);
};
