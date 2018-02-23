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

contract NameSpaceRegistrar {

    string public VERSION = "2";

    //We use bytes32 rather than string for namespaces & token symbols to allow these to be retrieved
    //by other contracts. String can not be returned within the EVM, only externally.

    //A token symbol can only be registered once under a given namespace (so a symbol always maps to exactly one owner)
    mapping (bytes32 => mapping (bytes32 => address)) public symbolToOwner;  //Maps namespaces to token symbols to owner address
    mapping (bytes32 => string) symbolDescription;                           //Maps token symbols to their description - this is only used internally within this contract

    address public admin;

    event AdminChange(address indexed _oldAdmin, address indexed _newAdmin);
    event RegisteredToken(bytes32 indexed _nameSpace, bytes32 _symbol, string _description, address indexed _owner);

    /**
     * @dev Constructor - sets the admin
     * the creation of the security token
     */
    function NameSpaceRegistrar() public
    {
      admin = msg.sender;
    }

    /**
     * @dev allows the admin address to set a new admin
     * @param _admin New admin address
     */
    function changeAdmin(address _admin) public {
      require(msg.sender == admin);
      AdminChange(admin, _admin);
      admin = _admin;
    }

    /**
     * @dev Registers a new token symbol and owner against a specific namespace
     * @param _nameSpace namespace
     * @param _symbol symbol
     * @param _owner owner
     */
    function registerToken(bytes32 _nameSpace, bytes32 _symbol, string _description, address _owner) public {
      require(msg.sender == admin);
      require(symbolToOwner[_nameSpace][_symbol] == address(0));
      symbolToOwner[_nameSpace][_symbol] = _owner;
      symbolDescription[_symbol] = _description;
      RegisteredToken(_nameSpace, _symbol, _description, _owner);
    }

    /**
     * @dev Returns the owner for a given symbol, under a given namespace
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getOwner(bytes32 _nameSpace, bytes32 _symbol) view public returns (address) {
      return symbolToOwner[_nameSpace][_symbol];
    }
}
