pragma solidity ^0.4.17;

interface ISTRegistrar {

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
        ) external;

    /// Allow new security token offering contract
    /// @param _contractAddress The security token offering contract's
    ///  public key address
    /// @param _fee The fee charged for the services provided in POLY
    function newSecurityTokenOfferingContract(address _contractAddress, uint256 _fee) public;

    function getCreator(address _contractAddress) public returns(address);
}
