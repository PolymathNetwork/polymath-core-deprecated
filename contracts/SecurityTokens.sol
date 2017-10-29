pragma solidity ^0.4.15;

import './SecurityToken.sol';
import './Ownable.sol';

contract SecurityTokens is Ownable {

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
    // Mapping of ticker name to Security Token details
    mapping(string => SecurityToken) securityTokens;

    // Security Token Offering Contract
    struct SecurityTokenOfferingContract {
      address creator;
      bool approved;
      uint256 fee;
    }
    // Mapping of contract creator address to contract details
    mapping(address => SecurityTokenOfferingContract) public securityTokenOfferingContracts;

    event LogNewSecurityToken(string indexed ticker, address securityTokenAddress, address owner);
    event LogNewSecurityTokenOffering(address contractAddress, bool approved);

    // Creates a new Security Token and saves it to the registry
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    function createSecurityToken (string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner, uint8 _type) external {
      if (SecurityTokenRegistry[_ticker] != 0) {
        revert();
      }
      // Create the new Security Token contract
      address newSecurityTokenAddress = new SecurityToken(_name, _ticker, _decimals, _totalSupply, _owner);

      // Update the registry
      SecurityTokenInformation memory newToken = securityTokens[_ticker];
      newToken.name = _name;
      newToken.decimals = _decimals;
      newToken.totalSupply = _totalSupply;
      newToken.owner = _owner;
      newToken.securityType = _type;
      newToken.tokenAddress = newSecurityTokenAddress;
      securityTokens[_ticker] = newToken;

      // Log event and update total Security Token count
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, owner);
      totalSecurityTokens++;
    }

    /// Allow new security token offering contract
    /// @param _contractAddress The security token offering contract's public key address
    /// @param _fee The fee charged for the services provided in POLY
    function newSecurityTokenOfferingContract(address _contractAddress, uint256 _fee) {
      require(_contractAddress != address(0));
      offeringContracts[_contractAddress] = SecurityTokenOfferingContract(_contractAddress, _fee, false);
      LogNewSecurityTokenOffering(_contractAddress, false);
    }

    /// Approve or reject a security token offering contract application
    /// @param _offeringAddress The legal delegate's public key address
    /// @param _approved Whether the security token offering contract was approved or not
    /// @param _fee the fee to perform the task
    function approveSecurityTokenOfferingContract(address _contractAddress, bool _approved, uint256 _fee) onlyOwner {
      require(_contractAddress != address(0));
      require(securityTokenOfferingContracts[_offeringAddress] != 0);
      if (_approved == true) {
        securityTokenOfferingContracts[_contractAddress].approved = true;
        securityTokenOfferingContracts[_contractAddress].fee = _fee;
        LogNewSecurityTokenOffering(_contractAddress, true);
      } else {
       securityTokenOfferingContracts[_offeringAddress] = address(0);
      }
    }

}
