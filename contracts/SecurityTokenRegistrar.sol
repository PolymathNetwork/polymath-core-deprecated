pragma solidity ^0.4.18;

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/

import './interfaces/ISecurityTokenRegistrar.sol';
import './interfaces/IERC20.sol';
import './SecurityToken.sol';
import './Compliance.sol';

/**
 * @title SecurityTokenRegistrar
 * @dev Contract use to register the security token on Polymath platform
 */

contract SecurityTokenRegistrar is ISecurityTokenRegistrar {

    string public VERSION = "2";
    SecurityToken securityToken;
    IERC20 public PolyToken;                                        // Address of POLY token
    address public polyCustomersAddress;                            // Address of the polymath-core Customers contract address
    address public polyComplianceAddress;                           // Address of the polymath-core Compliance contract address

    // Security Token
    struct SecurityTokenData {                                      // A structure that contains the specific info of each ST
      string nameSpace;
      uint256 totalSupply;
      address owner;
      uint8 decimals;
      string ticker;
      uint8 securityType;
    }

    mapping (string => address) nameSpace;                           // Mapping from nameSpace to owner
    mapping (address => SecurityTokenData) securityTokens;           // Mapping from securityToken address to data about the securityToken
    mapping (string => mapping (string => address)) tickers;         // Mapping from nameSpace, to a mapping of ticker name to correspondong securityToken addresses

    event LogNewSecurityToken(string _nameSpace, string _ticker, address indexed _securityTokenAddress, address indexed _owner, address _polyFeeAddress, uint256 _fee, uint8 _type);
    event LogFeeChange(string _nameSpace, uint256 _newFee);
    event LogPolyFeeAddressChange(string _nameSpace, address _newPolyFeeAddress);

    /**
     * @dev Constructor use to set the essentials addresses to facilitate
     * the creation of the security token
     */
    function SecurityTokenRegistrar(
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress
    ) public
    {
      require(_polyTokenAddress != address(0));
      require(_polyCustomersAddress != address(0));
      require(_polyComplianceAddress != address(0));
      PolyToken = IERC20(_polyTokenAddress);
      polyCustomersAddress = _polyCustomersAddress;
      polyComplianceAddress = _polyComplianceAddress;
      // Creating the instance of the compliance contract and assign the STR contract
      // address (this) into the compliance contract
      Compliance PolyCompliance = Compliance(polyComplianceAddress);
      require(PolyCompliance.setRegistrarAddress(this));
    }

    /**
     * @dev Creates a securityToken name space
     * @param _nameSpace Name space string
     * @param _owner Owner for this name space
     */
    function createNameSpace(string _nameSpace, address _owner) public {
      require(nameSpace[_nameSpace] == 0x0);
      require(_owner != 0x0);
      nameSpace[_nameSpace] = _owner;
    }

    /**
     * @dev Changes Polymath fee address
     * @param _nameSpace Name space string
     * @param _owner New owner for for this name space
     */
    function changeNameSpaceOwner(string _nameSpace, address _owner) public {
      require(msg.sender == nameSpace[_nameSpace]);
      nameSpace[_nameSpace] = _owner;
      LogPolyFeeAddressChange(_nameSpace, _owner);
    }

    /**
     * @dev Creates a new Security Token and saves it to the registry
     * @param _nameSpace Name space for this security token
     * @param _hostFee Fee requested by the host/namespace owner
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _decimals Decimals value for token
     * @param _owner Ethereum public key address of the security token owner
     * @param _type Type of security being tokenized
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     */
    function createSecurityToken (
      string _nameSpace,
      uint256 _hostFee,
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint8 _type,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) external
    {
      require(nameSpace[_nameSpace] == msg.sender);
      require(_totalSupply > 0);
      require(tickers[_nameSpace][_ticker] == 0x0);
      require(_lockupPeriod >= now);
      require(_owner != address(0));
      require(PolyToken.transferFrom(_owner, nameSpace[_nameSpace], _hostFee));
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0);
      address securityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _decimals,
        _owner,
        _lockupPeriod,
        _quorum,
        PolyToken,
        polyCustomersAddress,
        polyComplianceAddress
      );
      tickers[_nameSpace][_ticker] = securityTokenAddress;
      securityTokens[securityTokenAddress] = SecurityTokenData(
        _nameSpace,
        _totalSupply,
        _owner,
        _decimals,
        _ticker,
        _type
      );
      LogNewSecurityToken(_nameSpace, _ticker, securityTokenAddress, _owner, nameSpace[_nameSpace], _hostFee, _type);
    }

    //////////////////////////////
    ///////// Get Functions
    //////////////////////////////
    /**
     * @dev Get security token address by ticker name
     * @param _nameSpace Name space of the Scurity token
     * @param _ticker Symbol of the Scurity token
     * @return address _ticker
     */
    function getSecurityTokenAddress(string _nameSpace, string _ticker) public view returns (address) {
      return tickers[_nameSpace][_ticker];
    }

    /**
     * @dev Get Security token details by its ethereum address
     * @param _STAddress Security token address
     */
    function getSecurityTokenData(address _STAddress) public view returns (
      string,
      uint256,
      address,
      uint8,
      string,
      uint8
    ) {
      return (
        securityTokens[_STAddress].nameSpace,
        securityTokens[_STAddress].totalSupply,
        securityTokens[_STAddress].owner,
        securityTokens[_STAddress].decimals,
        securityTokens[_STAddress].ticker,
        securityTokens[_STAddress].securityType
      );
    }

}
