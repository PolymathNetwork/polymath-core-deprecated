pragma solidity ^0.4.18;

/*
  Allows issuers to reserve their token symbols under a given namespace ahead
  of actually generating their security token.
  SecurityTokenRegistrar would reference this contract and ensure that any token symbols
  registered here can only be created by their owner.
*/

/**
 * @title NameSpaceRegistrar
 * @dev Contract use to register the security token symbols
 */

interface INameSpaceRegistrar {

    /**
     * @dev allows the admin address to set a new admin
     * @param _admin admin address
     * @param _valid bool to indicate whether admin address is allowed
     */
    function changeAdmin(address _admin, bool _valid)  public;

    /**
     * @dev allows the owner of a token registration to change the owner
     * @param _nameSpace namespace
     * @param _symbol token symbol
     * @param _newOwner new owner
     */
    function changeTokenOwner(string _nameSpace, string _symbol, address _newOwner) public; 

    /**
     * @dev Registers a new token symbol and owner against a specific namespace
     * @param _nameSpace namespace
     * @param _symbol token symbol
     * @param _description token description
     * @param _contact token contract details e.g. email
     * @param _owner owner
     */
    function registerToken(string _nameSpace, string _symbol, string _description, string _contact, address _owner) public; 

    /**
     * @dev Returns the owner and timestamp for a given symbol, under a given namespace - can be called by other contracts
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getDetails(string _nameSpace, string _symbol) view public returns (address, uint256);

    /**
     * @dev Returns the description and contact details for a given symbol, under a given namespace - cannot be called by other contracts
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getDescription(string _nameSpace, string _symbol) view public returns (string);

}
