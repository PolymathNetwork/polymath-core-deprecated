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

    struct SymbolDetails {
      address owner;
      uint256 timestamp;
      string description;
    }

    mapping (string => mapping (string => SymbolDetails)) symbolDetails;    //Tracks details for namespace / symbol registrations
    mapping (address => bool) hasRegistered;                                //Tracks addresses that have registered tokens, only allow one registration per address
    mapping (address => bool) public admins;                                //Track valid admin addresses

    event AdminChange(address indexed _admin, bool _valid);
    event RegisteredToken(string _nameSpace, string _symbol, string _description, string _contact, address indexed _owner, address indexed _admin, uint256 _timestamp);
    event TokenOwnerChange(string _nameSpace, string _symbol, address indexed _oldOwner, address indexed _newOwner);

    // Check that msg.sender is an admin
    modifier onlyAdmin {
      require(admins[msg.sender]);
      _;
    }

    /**
     * @dev Constructor - sets the admin
     * the creation of the security token
     */
    function NameSpaceRegistrar() public
    {
      admins[msg.sender] = true;
    }

    /**
     * @dev allows the admin address to set a new admin
     * @param _admin admin address
     * @param _valid bool to indicate whether admin address is allowed
     */
    function changeAdmin(address _admin, bool _valid) onlyAdmin public {
      //You can't remove yourself as an admin
      require(msg.sender != _admin);
      admins[_admin] = _valid;
      AdminChange(_admin, _valid);
    }

    /**
     * @dev allows the owner of a token registration to change the owner
     * @param _nameSpace namespace
     * @param _symbol token symbol
     * @param _newOwner new owner
     */
    function changeTokenOwner(string _nameSpace, string _symbol, address _newOwner) public {
      require(symbolDetails[_nameSpace][_symbol].owner == msg.sender);
      symbolDetails[_nameSpace][_symbol].owner = _newOwner;
      TokenOwnerChange(_nameSpace, _symbol, msg.sender, _newOwner);
    }

    /**
     * @dev Registers a new token symbol and owner against a specific namespace
     * @param _nameSpace namespace
     * @param _symbol token symbol
     * @param _description token description
     * @param _contact token contract details e.g. email
     * @param _owner owner
     */
    function registerToken(string _nameSpace, string _symbol, string _description, string _contact, address _owner) onlyAdmin public {
      require(!hasRegistered[_owner]);
      require(_owner != address(0));
      require(symbolDetails[_nameSpace][_symbol].owner == address(0));
      hasRegistered[_owner] = true;
      symbolDetails[_nameSpace][_symbol].owner = _owner;
      symbolDetails[_nameSpace][_symbol].description = _description;
      symbolDetails[_nameSpace][_symbol].timestamp = now;
      RegisteredToken(_nameSpace, _symbol, _description, _contact, _owner, msg.sender, now);
    }

    /**
     * @dev Returns the owner and timestamp for a given symbol, under a given namespace - can be called by other contracts
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getDetails(string _nameSpace, string _symbol) view public returns (address, uint256) {
      return (symbolDetails[_nameSpace][_symbol].owner, symbolDetails[_nameSpace][_symbol].timestamp);
    }

    /**
     * @dev Returns the description and contact details for a given symbol, under a given namespace - cannot be called by other contracts
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getDescription(string _nameSpace, string _symbol) view public returns (string) {
      return symbolDetails[_nameSpace][_symbol].description;
    }

}
