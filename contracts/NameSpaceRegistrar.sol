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

    mapping (string => mapping (string => address)) symbolOwner;          //Maps namespaces to token symbols to owner address
    mapping (string => mapping (string => uint256)) symbolTimestamp;      //Maps namespaces to token symbols to registration timestamp
    mapping (string => mapping (string => string)) symbolDescription;     //Maps token symbols to their description - this is only used internally within this contract
    mapping (string => mapping (string => string)) symbolContact;         //Maps token symbols to their contact details - this is only used internally within this contract
    mapping (address => bool) hasRegistered;                              //Tracks addresses that have registered tokens, only allow one registration per address
    mapping (address => bool) public admins;                              //Track valid admin addresses

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
      require(symbolOwner[_nameSpace][_symbol] == msg.sender);
      symbolOwner[_nameSpace][_symbol] = _newOwner;
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
      require(symbolOwner[_nameSpace][_symbol] == address(0));
      hasRegistered[_owner] = true;
      symbolOwner[_nameSpace][_symbol] = _owner;
      symbolDescription[_nameSpace][_symbol] = _description;
      symbolContact[_nameSpace][_symbol] = _contact;
      symbolTimestamp[_nameSpace][_symbol] = now;
      RegisteredToken(_nameSpace, _symbol, _description, _contact, _owner, msg.sender, now);
    }

    /**
     * @dev Returns the owner and timestamp for a given symbol, under a given namespace - can be called by other contracts
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getDetails(string _nameSpace, string _symbol) view public returns (address, uint256) {
      return (symbolOwner[_nameSpace][_symbol], symbolTimestamp[_nameSpace][_symbol]);
    }

    /**
     * @dev Returns the description and contact details for a given symbol, under a given namespace - cannot be called by other contracts
     * @param _nameSpace namespace
     * @param _symbol symbol
     */
    function getDescription(string _nameSpace, string _symbol) view public returns (string, string) {
      return (symbolDescription[_nameSpace][_symbol], symbolDescription[_nameSpace][_symbol]);
    }

}
