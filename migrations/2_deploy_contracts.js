const SafeMath = artifacts.require('./math/SafeMath.sol');
const Ownable = artifacts.require('./Ownable.sol');
var SecurityToken = artifacts.require("./SecurityToken.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.deploy(Ownable);

  deployer.link(Ownable, SecurityToken);
  deployer.link(SafeMath, SecurityToken);

  deployer.deploy(SecurityToken);
};
