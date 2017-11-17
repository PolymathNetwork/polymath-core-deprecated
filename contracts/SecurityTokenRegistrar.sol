pragma solidity ^0.4.15;

import './SafeMath.sol';
import './SecurityToken.sol';
import './Ownable.sol';
import './interfaces/ISTRegistrar.sol';


contract SecurityTokenRegistrar is Ownable, ISTRegistrar {

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
        address tokenAddress;
        uint8 securityType;
    }

    // Mapping of ticker name to Security Token details
    mapping(string => SecurityTokenData) securityTokenRegistrar; // Can't be public, why?

    // Security Token Offering Contract
    struct SecurityTokenOfferingContract {
        address creator;
        uint256 fee;
    }

    // Mapping of contract address to contract details
    mapping(address => SecurityTokenOfferingContract) public securityTokenOfferingContracts;

    event LogNewSecurityToken(string indexed ticker, address securityTokenAddress, address owner);
    event LogNewSecurityTokenOffering(address contractAddress);

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

    // Creates a new Security Token and saves it to the registry
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    /// @param _type Type of security being tokenized
    function createSecurityToken (
        string _name, 
        string _ticker, 
        uint256 _totalSupply, 
        address _owner, 
        bytes32 _template, 
        uint8 _type
    ) external
    {
    //TODO require(securityTokenRegistrar[_ticker] != address(0));

    // Collect creation fee
        PolyToken(polyTokenAddress).transferFrom(_owner, this, 1000);

        // Create the new Security Token contract
        address newSecurityTokenAddress = new SecurityToken(
            _name, 
            _ticker, 
            _totalSupply, 
            _owner, 
            _template, 
            polyTokenAddress, 
            polyCustomersAddress, 
            polyComplianceAddress
        );

        // Update the registry
        SecurityTokenData memory newToken = securityTokenRegistrar[_ticker];
        newToken.name = _name;
        newToken.decimals = 0;
        newToken.totalSupply = _totalSupply;
        newToken.owner = _owner;
        newToken.securityType = _type;
        newToken.tokenAddress = newSecurityTokenAddress;
        securityTokenRegistrar[_ticker] = newToken;

        // Log event and update total Security Token count
        LogNewSecurityToken(_ticker, newSecurityTokenAddress, owner);
        totalSecurityTokens++;
    }

    /// Allow new security token offering contract
    /// @param _contractAddress The security token offering contract's public key address
    /// @param _fee The fee charged for the services provided in POLY
    function newSecurityTokenOfferingContract(
        address _contractAddress,
        uint256 _fee
    ) public
    {
        require(_contractAddress != address(0));
        SecurityTokenOfferingContract memory newSTO = SecurityTokenOfferingContract({creator: msg.sender, fee: _fee});
        securityTokenOfferingContracts[_contractAddress] = newSTO;
        LogNewSecurityTokenOffering(_contractAddress);
    }


    /// @notice This is a basic getter function to allow access to the
    ///  creator of a given STO contract through an interface.
    /// @param _contractAddress An STO contract
    /// @returns address The address of the STO contracts creator
    function getCreator(address _contractAddress) public returns(address) {
        return securityTokenOfferingContracts[_contractAddress].creator;
    }

    /// @notice This is a basic getter function to allow access to the
    ///  fee of a given STO contract through an interface.
    /// @param _contractAddress An STO contract
    /// @returns address The address of the STO contracts fee
    function getFee(address _contractAddress) public returns(uint256) {
        return securityTokenOfferingContracts[_contractAddress].fee;
    }

}
