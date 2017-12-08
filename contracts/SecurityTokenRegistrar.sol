pragma solidity ^0.4.18;

import './SafeMath.sol';
import './SecurityToken.sol';
import './Ownable.sol';
import './interfaces/ISTRegistrar.sol';


contract SecurityTokenRegistrar is ISTRegistrar {

    uint256 public totalSecurityTokens;
    address public polyTokenAddress;
    address public polyCustomersAddress;
    address public polyComplianceAddress;
    PolyToken POLY;

    // Security Token
    struct SecurityTokenData {
        string name;
        uint8 decimals;
        uint256 totalSupply;
        address owner;
        bytes8 ticker;
        uint8 securityType;
        bytes32 template;
    }
    mapping(address => SecurityTokenData) securityTokens;

    // Mapping of ticker name to Security Token
    mapping(bytes8 => address) tickers;

    event LogNewSecurityToken(bytes8 indexed ticker, address securityTokenAddress, uint256 _etherRaise, address owner);

    // Constructor
    function SecurityTokenRegistrar(
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public
    {
        polyTokenAddress = _polyTokenAddress;
        polyCustomersAddress = _polyCustomersAddress;
        polyComplianceAddress = _polyComplianceAddress;
    }

    /**
        @dev Creates a new Security Token and saves it to the registry
        @param _name Name of the security token
        @param _ticker Ticker name of the security
        @param _totalSupply Total amount of tokens being created
        @param _owner Ethereum public key address of the security token owner
        @param _host The host of the security token wizard
        @param _fee Fee being requested by the wizard host
        @param _type Type of security being tokenized
        @param _etherRaise Amount of ether being raised
        @param _polyRaise Amount of POLY being raised
        @param _lockupPeriod Length of time raised POLY will be locked up for dispute
        @param _quorum Percent of initial investors required to freeze POLY raise
     */
     
    function createSecurityToken (
      string _name,
      bytes8 _ticker,
      uint256 _totalSupply,
      address _owner,
      address _host,
      uint256 _fee,
      uint8 _type,
      uint256 _etherRaise,
      uint256 _polyRaise,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) external {
      require(_owner != address(0));
      require(tickers[_ticker] == address(0));

      // Collect creation fee
      PolyToken(polyTokenAddress).transferFrom(msg.sender, _host, _fee);

      // Create the new Security Token contract
      address newSecurityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _owner,
        _polyRaise,
        _lockupPeriod,
        _quorum,
        polyTokenAddress,
        polyCustomersAddress,
        polyComplianceAddress,
        this
      );

      // Update the registry
      SecurityTokenData memory st = securityTokens[newSecurityTokenAddress];
      st.name = _name;
      st.decimals = 0;
      st.totalSupply = _totalSupply;
      st.owner = _owner;
      st.securityType = _type;
      st.ticker = _ticker;
      st.template = 0x0;
      securityTokens[newSecurityTokenAddress] = st;
      tickers[_ticker] = newSecurityTokenAddress;

      // Log event and update total Security Token count
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, _etherRaise, _owner);
      totalSecurityTokens++;
    }

}
