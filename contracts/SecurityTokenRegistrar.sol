pragma solidity ^0.4.18;

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/

import './interfaces/ISTRegistrar.sol';
import './interfaces/IERC20.sol';
import './SecurityToken.sol';
import './Compliance.sol';

/**
 * @title SecurityTokenRegistrar
 * @dev Contract use to register the security token on Polymath platform
 */

contract SecurityTokenRegistrar is ISTRegistrar {

    string public VERSION = "1";
    SecurityToken securityToken;
    address public polyTokenAddress;                                // Address of POLY token
    address public polyCustomersAddress;                            // Address of the polymath-core Customers contract address
    address public polyComplianceAddress;                           // Address of the polymath-core Compliance contract address
    uint256 public fee;                                             // Fee paid to PolyMath to launch a new ST
    address public polyFeeAddress;                                  // Address which collects fees
    address public owner;                                           // Contract owner

    // Security Token
    struct SecurityTokenData {                                      // A structure that contains the specific info of each ST
      uint256 totalSupply;                                          // created ever using the Polymath platform
      address owner;
      uint8 decimals;
      string ticker;
      uint8 securityType;
    }
    mapping(address => SecurityTokenData) securityTokens;           // Array contains the details of security token corresponds to security token address
    mapping(string => address) tickers;                             // Mapping of ticker name to Security Token

    event LogNewSecurityToken(string _ticker, address indexed _securityTokenAddress, address indexed _owner, address _polyFeeAddress, uint256 _fee, uint8 _type);
    event LogFeeChange(uint256 _newFee);
    event LogPolyFeeAddressChange(address _newPolyFeeAddress);

    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    /**
     * @dev Constructor use to set the essentials addresses to facilitate
     * the creation of the security token
     */
    function SecurityTokenRegistrar(
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress,
      address _polyFeeAddress,
      uint256 _fee
    ) public
    {
      require(_polyTokenAddress != address(0));
      require(_polyCustomersAddress != address(0));
      require(_polyComplianceAddress != address(0));
      require(_polyFeeAddress != address(0));
      owner = msg.sender;
      polyTokenAddress = _polyTokenAddress;
      polyCustomersAddress = _polyCustomersAddress;
      polyComplianceAddress = _polyComplianceAddress;
      polyFeeAddress = _polyFeeAddress;
      fee = _fee;
      // Creating the instance of the compliance contract and assign the STR contract
      // address (this) into the compliance contract
      Compliance PolyCompliance = Compliance(polyComplianceAddress);
      require(PolyCompliance.setRegistrarAddress(this));
    }

    /**
     * @dev Changes Polymath fee
     * @param _fee New fee for security token creation
     */
    function changeFee(uint256 _fee) onlyOwner public {
      fee = _fee;
      LogFeeChange(fee);
    }

    /**
     * @dev Changes Polymath fee address
     * @param _polyFeeAddress New polymath address for security token creation fee
     */
    function changePolyFeeAddress(address _polyFeeAddress) onlyOwner public {
      polyFeeAddress = _polyFeeAddress;
      LogPolyFeeAddressChange(polyFeeAddress);
    }

    /**
     * @dev Creates a new Security Token and saves it to the registry
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _decimals Decimals value for token
     * @param _owner Ethereum public key address of the security token owner
     * @param _maxPoly Amount of maximum poly issuer want to raise
     * @param _type Type of security being tokenized
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     */
    function createSecurityToken (
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint256 _maxPoly,
      uint8 _type,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) external
    {
      require(_totalSupply > 0 && _maxPoly > 0);
      require(tickers[_ticker] == 0x0);
      require(_lockupPeriod >= now);
      require(_owner != address(0));
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0);
      IERC20 POLY = IERC20(polyTokenAddress);
      require(POLY.transferFrom(msg.sender, polyFeeAddress, fee));
      address newSecurityTokenAddress = initialiseSecurityToken(_name, _ticker, _totalSupply, _decimals, _owner, _maxPoly, _type, _lockupPeriod, _quorum);
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, _owner, polyFeeAddress, fee, _type);
    }

    function initialiseSecurityToken(
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint256 _maxPoly,
      uint8 _type,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) internal returns (address)
    {
      address newSecurityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _decimals,
        _owner,
        _maxPoly,
        _lockupPeriod,
        _quorum,
        polyTokenAddress,
        polyCustomersAddress,
        polyComplianceAddress
      );
      tickers[_ticker] = newSecurityTokenAddress;
      securityTokens[newSecurityTokenAddress] = SecurityTokenData(
        _totalSupply,
        _owner,
        _decimals,
        _ticker,
        _type
      );
      return newSecurityTokenAddress;
    }

    //////////////////////////////
    ///////// Get Functions
    //////////////////////////////
    /**
     * @dev Get security token address by ticker name
     * @param _ticker Symbol of the Scurity token
     * @return address _ticker
     */
    function getSecurityTokenAddress(string _ticker) public constant returns (address) {
      return tickers[_ticker];
    }

    /**
     * @dev Get Security token details by its ethereum address
     * @param _STAddress Security token address
     */
    function getSecurityTokenData(address _STAddress) public constant returns (
      uint256,
      address,
      uint8,
      string,
      uint8
    ) {
      return (
        securityTokens[_STAddress].totalSupply,
        securityTokens[_STAddress].owner,
        securityTokens[_STAddress].decimals,
        securityTokens[_STAddress].ticker,
        securityTokens[_STAddress].securityType
      );
    }

}
