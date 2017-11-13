pragma solidity ^0.4.15;

import './SafeMath.sol';
import './SecurityToken.sol';
import './Ownable.sol';

contract SecurityTokenRegistrar is Ownable {

    uint256 public totalSecurityTokens;
    address public polyTokenAddress;
    address public polyCustomersAddress;
    PolyToken POLY;

    // Security Token
    struct SecurityTokenData {
      string name;
      uint8 decimals;
      uint256 totalSupply;
      address owner;
      address tokenAddress;
      uint8 securityType;
      uint256 developerFee;
    }

    // Mapping of ticker name to Security Token details
    mapping(string => SecurityTokenData) public securityTokenRegistrar;

    // Security Token Offering Contract
    struct SecurityTokenOfferingContract {
      address creator;
      uint256 fee;
    }

    // Mapping of contract creator address to contract details
    mapping(address => SecurityTokenOfferingContract) public securityTokenOfferingContracts;
    //dk - i think this is wrong, should be STO contract address - nov 3
    event LogNewSecurityToken(string indexed ticker, address securityTokenAddress, address owner);
    event LogNewSecurityTokenOffering(address contractAddress);

    // Constructor
    function securityTokenRegistrar(address _polyTokenAddress, address _polyCustomersAddress) {
      polyTokenAddress = _polyTokenAddress;
      polyCustomersAddress = _polyCustomersAddress;
    }

    // Creates a new Security Token and saves it to the registry
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    /// @param _type Type of security being tokenized
    function createSecurityToken (string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner, uint8 _type, uint256 _fee) external {
      //TODO require(securityTokenRegistrar[_ticker] != address(0));

      // Collect developer fee
      PolyToken(polyTokenAddress).transferFrom(_owner, this, _fee);

      // Create the new Security Token contract
      address newSecurityTokenAddress = new SecurityToken(_name, _ticker, _decimals, _totalSupply, _owner, polyTokenAddress, polyCustomersAddress);

      // Update the registry
      SecurityTokenData memory newToken = securityTokenRegistrar[_ticker];
      newToken.name = _name;
      newToken.decimals = _decimals;
      newToken.totalSupply = _totalSupply;
      newToken.owner = _owner;
      newToken.securityType = _type;
      newToken.developerFee = _fee;
      newToken.tokenAddress = newSecurityTokenAddress;
      securityTokenRegistrar[_ticker] = newToken;

      // Log event and update total Security Token count
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, owner);
      totalSecurityTokens++;
    }

    /// Allow new security token offering contract
    /// @param _contractAddress The security token offering contract's public key address
    /// @param _fee The fee charged for the services provided in POLY
    function newSecurityTokenOfferingContract(address _contractAddress, uint256 _fee) {
      require(_contractAddress != address(0));
      SecurityTokenOfferingContract memory newSTO = SecurityTokenOfferingContract({creator: msg.sender, fee: _fee});
      securityTokenOfferingContracts[_contractAddress] = newSTO;
      LogNewSecurityTokenOffering(_contractAddress);
    }

}
