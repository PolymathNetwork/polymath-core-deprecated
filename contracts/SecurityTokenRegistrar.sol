pragma solidity ^0.4.18;

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/
import './interfaces/ISecurityTokenRegistrar.sol';
import './interfaces/IERC20.sol';
import './SecurityToken.sol';

/**
 * @title SecurityTokenRegistrar
 * @dev Contract use to register the security token on Polymath platform
 */

contract SecurityTokenRegistrar is ISecurityTokenRegistrar {

    string public VERSION = "2";
    IERC20 public PolyToken;                                        // Address of POLY token
    address public polyCustomersAddress;                            // Address of the polymath-core Customers contract address
    address public polyComplianceAddress;                           // Address of the polymath-core Compliance contract address

    struct NameSpaceData {
      address owner;
      uint256 fee;
    }

    // Security Token
    struct SecurityTokenData {                                      // A structure that contains the specific info of each ST
      string nameSpace;
      string ticker;
      address owner;
      uint8 securityType;
    }

    mapping (string => NameSpaceData) nameSpaceData;                 // Mapping from nameSpace to owner / fee of nameSpace
    mapping (address => SecurityTokenData) securityTokens;           // Mapping from securityToken address to data about the securityToken
    mapping (string => mapping (string => address)) tickers;         // Mapping from nameSpace, to a mapping of ticker name to correspondong securityToken addresses

    event LogNewSecurityToken(string _nameSpace, string _ticker, address indexed _securityTokenAddress, address indexed _owner, uint8 _type);
    event LogNameSpaceChange(string _nameSpace, address _newOwner, uint256 _newFee);

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
    }

    /**
     * @dev Creates a securityToken name space
     * @param _nameSpace Name space string
     * @param _owner Owner for this name space
     * @param _fee Fee for this name space
     */
    function createNameSpace(string _nameSpace, address _owner, uint256 _fee) public {
      require(nameSpaceData[_nameSpace].owner == 0x0);
      require(_owner != 0x0);
      nameSpaceData[_nameSpace].owner = _owner;
      nameSpaceData[_nameSpace].fee = _fee;
    }
    /**
     * @dev Changes name space fee
     * @param _nameSpace Name space string
     * @param _fee New fee for security token creation for this name space
     */
    function changeNameSpace(string _nameSpace, address _owner, uint256 _fee) public {
      require(msg.sender == nameSpaceData[_nameSpace].owner);
      nameSpaceData[_nameSpace].fee = _fee;
      nameSpaceData[_nameSpace].owner = _owner;
      LogNameSpaceChange(_nameSpace, _owner, _fee);
    }

    /**
     * @dev Creates a new Security Token and saves it to the registry
     * @param _nameSpaceName Name space for this security token
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
      string _nameSpaceName,
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
      require(_totalSupply > 0);
      require(_lockupPeriod >= now);
      NameSpaceData storage nameSpace = nameSpaceData[_nameSpaceName];
      require(tickers[_nameSpaceName][_ticker] == 0x0);
      require(nameSpace.owner != 0x0);
      require(_owner != address(0));
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0);
      require(PolyToken.transferFrom(msg.sender, nameSpace.owner, nameSpace.fee));
      initialiseSecurityToken(_nameSpaceName, _name, _ticker, _totalSupply, _decimals, _owner, _type, _lockupPeriod, _quorum);
    }

    function initialiseSecurityToken(
      string _nameSpace,
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint8 _type,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) internal
    {
      address newSecurityTokenAddress = new SecurityToken(
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
      tickers[_nameSpace][_ticker] = newSecurityTokenAddress;
      securityTokens[newSecurityTokenAddress] = SecurityTokenData(
        _nameSpace,
        _ticker,
        _owner,
        _type
      );
      LogNewSecurityToken(_nameSpace, _ticker, newSecurityTokenAddress, _owner, _type);
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
      string,
      address,
      uint8
    ) {
      return (
        securityTokens[_STAddress].nameSpace,
        securityTokens[_STAddress].ticker,
        securityTokens[_STAddress].owner,
        securityTokens[_STAddress].securityType
      );
    }

}
