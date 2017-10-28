pragma solidity ^0.4.15;

import './SecurityToken.sol';
import './Ownable.sol';

contract SecurityTokenRegistry is Ownable {

    uint256 public totalSecurityTokens;

    // Security Token
    struct SecurityToken {
      string name;
      uint8 decimals;
      uint256 totalSupply;
      address owner;
      address tokenAddress;
      uint8 securityType;
    }
    mapping(string => SecurityToken) SecurityTokenRegistry;

    event LogNewSecurityToken(string indexed ticker, address securityTokenAddress, address owner);

    // Creates a new Security Token and saves it to the registry
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    function newSecurityToken (string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner, uint8 _type) external {
      if (SecurityTokenRegistry[_ticker] != 0) {
        revert();
      }
      // Create the new Security Token contract
      address newSecurityTokenAddress = new SecurityToken(_name, _ticker, _decimals, _totalSupply, _owner);

      // Update the registry
      SecurityTokenInformation memory newToken = SecurityTokenRegistry[_ticker];
      newToken.name = _name;
      newToken.decimals = _decimals;
      newToken.totalSupply = _totalSupply;
      newToken.owner = _owner;
      newToken.securityType = _type;
      newToken.tokenAddress = newSecurityTokenAddress;
      SecurityTokenRegistry[_ticker] = newToken;

      // Log event and update total Security Token count
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, owner);
      totalSecurityTokens++;
    }

}
