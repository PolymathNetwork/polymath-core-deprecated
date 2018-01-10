pragma solidity ^0.4.18;

/*
  The Polymath Security Token Registrar provides a way to lookup security token details
  from a single place and allows wizard creators to earn POLY fees by uploading to the
  registrar.
*/

import './interfaces/ISTRegistrar.sol';
import './PolyToken.sol';
import './SecurityToken.sol';

contract SecurityTokenRegistrar is ISTRegistrar {

    address public polyTokenAddress;
    address public polyCustomersAddress;
    address public polyComplianceAddress;

    // Security Token
    struct SecurityTokenData {
      uint256 totalSupply;
      address owner;
      string ticker;
      uint8 securityType;
    }
    mapping(address => SecurityTokenData) securityTokens;

    // Mapping of ticker name to Security Token
    mapping(string => address) tickers;

    event LogNewSecurityToken(string ticker, address securityTokenAddress, address owner, address host, uint256 fee, uint8 _type);

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

    /* @dev Creates a new Security Token and saves it to the registry
    @param _name Name of the security token
    @param _ticker Ticker name of the security
    @param _totalSupply Total amount of tokens being created
    @param _owner Ethereum public key address of the security token owner
    @param _host The host of the security token wizard
    @param _fee Fee being requested by the wizard host
    @param _type Type of security being tokenized
    @param _maxPoly Amount of POLY being raised
    @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    @param _quorum Percent of initial investors required to freeze POLY raise */
    function createSecurityToken (
      string _name,
      string _ticker,
      uint256 _totalSupply,
      address _owner,
      address _host,
      uint256 _fee,
      uint8 _type,
      uint256 _maxPoly,
      uint256 _lockupPeriod,
      uint8 _quorum
    ) external
    {
      PolyToken POLY = PolyToken(polyTokenAddress);
      POLY.transferFrom(msg.sender, _host, _fee);
      address newSecurityTokenAddress = new SecurityToken(
        _name,
        _ticker,
        _totalSupply,
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
        _ticker,
        _type
      );
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, _owner, _host, _fee, _type);
    }

    // Get security token address by ticker name
    function getSecurityTokenAddress(string _ticker) public constant returns (address) {
      return tickers[_ticker];
    }

    // Get Security token details by its ethereum address
    function getSecurityTokenData(address _STAddress) public constant returns (
      uint256 totalSupply,
      address owner,
      string ticker,
      uint8 securityType
    ) {
      return (
        securityTokens[_STAddress].totalSupply,
        securityTokens[_STAddress].owner,
        securityTokens[_STAddress].ticker,
        securityTokens[_STAddress].securityType
      );
    }

}
