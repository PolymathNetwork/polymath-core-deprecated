pragma solidity ^0.4.18;

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/
import './interfaces/ISecurityTokenRegistrar.sol';
import './interfaces/IERC20.sol';
import './SecurityToken.sol';
import './interfaces/INameSpaceRegistrar.sol';

/**
 * @title SecurityTokenRegistrar
 * @dev Contract use to register the security token on Polymath platform
 */
contract SecurityTokenRegistrar is ISecurityTokenRegistrar {

    string public VERSION = "2";
    IERC20 public PolyToken;                                        // Address of POLY token
    address public polyCustomersAddress;                            // Address of the polymath-core Customers contract address
    address public polyComplianceAddress;                           // Address of the polymath-core Compliance contract address
    INameSpaceRegistrar public polyNameSpaceRegistrar;              // NameSpaceRegistrar contract pointer


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
    event LogNameSpaceCreated(string _nameSpace, address _owner, uint256 _fee);
    event LogNameSpaceChange(string _nameSpace, address _newOwner, uint256 _newFee);

    /**
     * @dev Constructor use to set the essentials addresses to facilitate
     * the creation of the security token
     */
    function SecurityTokenRegistrar(
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress,
      address _polyNameSpaceRegistrarAddress
    ) public
    {
      require(_polyTokenAddress != address(0));
      require(_polyCustomersAddress != address(0));
      require(_polyComplianceAddress != address(0));
      require(_polyNameSpaceRegistrarAddress != address(0));      
      PolyToken = IERC20(_polyTokenAddress);
      polyCustomersAddress = _polyCustomersAddress;
      polyComplianceAddress = _polyComplianceAddress;
      polyNameSpaceRegistrar = INameSpaceRegistrar(_polyNameSpaceRegistrarAddress);
    }

    /**
     * @dev Creates a securityToken name space
     * @param _nameSpace Name space string
     * @param _fee Fee for this name space
     */
    function createNameSpace(string _nameSpace, uint256 _fee) public {
      require(bytes(_nameSpace).length > 0);
      string memory nameSpace = lower(_nameSpace);
      require(nameSpaceData[nameSpace].owner == address(0));
      nameSpaceData[nameSpace].owner = msg.sender;
      nameSpaceData[nameSpace].fee = _fee;
      LogNameSpaceCreated(nameSpace, msg.sender, _fee);
    }

    /**
     * @dev changes a string to lower case
     * @param _base string to change
     */
    function lower(string _base) internal pure returns (string) {
      bytes memory _baseBytes = bytes(_base);
      for (uint i = 0; i < _baseBytes.length; i++) {
       bytes1 b1 = _baseBytes[i];
       if (b1 >= 0x41 && b1 <= 0x5A) {
         b1 = bytes1(uint8(b1)+32);
       }
       _baseBytes[i] = b1;
      }
      return string(_baseBytes);
    }

    /**
     * @dev Changes name space fee
     * @param _nameSpace Name space string
     * @param _fee New fee for security token creation for this name space
     */
    function changeNameSpace(string _nameSpace, uint256 _fee) public {
      string memory nameSpace = lower(_nameSpace);
      require(msg.sender == nameSpaceData[nameSpace].owner);
      nameSpaceData[nameSpace].fee = _fee;
      LogNameSpaceChange(nameSpace, msg.sender, _fee);
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
     */
    function createSecurityToken (
      string _nameSpaceName,
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint8 _type
    ) external
    {
      require(_totalSupply > 0);
      NameSpaceData storage nameSpace = nameSpaceData[_nameSpaceName];
      require(tickers[_nameSpaceName][_ticker] == address(0));
      require(nameSpace.owner != address(0));
      require(_owner != address(0));
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0);

      var(, _tickerTimeStamp) = polyNameSpaceRegistrar.getDetails(_nameSpaceName, _ticker);     
      require(_tickerTimeStamp + 90 days <= now);

      require(PolyToken.transferFrom(msg.sender, nameSpace.owner, nameSpace.fee));

      address newSecurityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _decimals,
        _owner,
        PolyToken,
        polyCustomersAddress,
        polyComplianceAddress
      );
      tickers[_nameSpaceName][_ticker] = newSecurityTokenAddress;
      securityTokens[newSecurityTokenAddress] = SecurityTokenData(
        _nameSpaceName,
        _ticker,
        _owner,
        _type
      );
      LogNewSecurityToken(_nameSpaceName, _ticker, newSecurityTokenAddress, _owner, _type);
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

    /**
     * @dev Get the name space data
     * @param _nameSpace Name space string.
     */
     function getNameSpaceData(string _nameSpace) public view returns(address, uint256) {
       string memory nameSpace = lower(_nameSpace); 
       return (
         nameSpaceData[nameSpace].owner,
         nameSpaceData[nameSpace].fee
       );
     }  
}
