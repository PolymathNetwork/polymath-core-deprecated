pragma solidity ^0.4.18;

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal returns (uint256) {
        return a < b ? a : b;
    }
}

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// An ERC20 token standard faucet





contract PolyToken is IERC20 {

    using SafeMath for uint256;
    uint256 public totalSupply = 1000000;
    string public name = "Polymath Network";
    uint8 public decimals = 18;
    string public symbol = "POLY";

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Token faucet - Not part of the ERC20 standard */
    function getTokens (uint256 _amount) public {
        balances[msg.sender] += _amount;
        totalSupply += _amount;
    }

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool) {
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/*
Polymath customer registry is used to ensure regulatory compliance
of the investors, provider, and issuers. The customers registry is a central
place where ethereum addresses can be whitelisted to purchase certain security
tokens based on their verifications by providers.
*/

contract Customers {

    PolyToken POLY;

    // A Customer
    struct Customer {
        bytes32 jurisdiction;
        uint8 role;
        bool verified;
        bool accredited;
        bool flagged;
        bytes32 proof;
        uint256 expires;
    }

    // Customers
    mapping (address => mapping (address => Customer)) customers;

    // KYC/Accreditation Provider
    struct Provider {
        string name;
        bytes32 details;
        uint256 fee;
    }

    // KYC/Accreditation Providers
    mapping(address => Provider) public providers;

    // Notifications
    event NewProvider(address providerAddress, string name, bytes32 details);
    event NewCustomer(address customer, address provider, bytes32 jurisdiction, uint8 role, bytes32 proof, bool verified);

    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    // Constructor
    function Customers(address _polyTokenAddress) public {
        POLY = PolyToken(_polyTokenAddress);
    }

    /// Allow new provider applications
    /// @param _providerAddress The provider's public key address
    /// @param _name The provider's name
    /// @param _details A SHA256 hash of the new providers details
    /// @param _fee The fee charged for customer verification
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public {
        require(_providerAddress != address(0));
        require(providers[_providerAddress].details != 0);
        // Require 10,000 POLY fee
        POLY.transferFrom(_providerAddress, this, 10000);
        providers[_providerAddress].name = _name;
        providers[_providerAddress].details = _details;
        providers[_providerAddress].fee = _fee;
        NewProvider(_providerAddress, _name, _details);
    }

    /// Allow new investor applications
    /// @param _jurisdiction The jurisdiction code of the customer
    /// @param _provider The provider selected by the customer
    ///  to do verification
    /// @param _role The type of customer - investor:1, issuer:2, delegate:3
    /// @param _proof The SHA256 hash of the documentation provided
    ///  to prove identity
    function newCustomer(bytes32 _jurisdiction, address _provider, uint8 _role, bytes32 _proof) public {
        customers[_provider][msg.sender].jurisdiction = _jurisdiction;
        customers[_provider][msg.sender].role = _role;
        customers[_provider][msg.sender].verified = false;
        customers[_provider][msg.sender].accredited = false;
        customers[_provider][msg.sender].flagged = false;
        customers[_provider][msg.sender].proof = _proof;
        NewCustomer(msg.sender, _provider, _jurisdiction, _role, _proof, false);
    }

    /// Verify an investor
    /// @param _customer The customer's public key address
    /// @param _jurisdiction The jurisdiction code of the customer
    /// @param _role The type of customer - investor:1 or issuer:2
    /// @param _accredited Whether the customer is accredited or
    ///  not (only applied to investors)
    /// @param _proof The SHA256 hash of the documentation provided
    ///  to prove identity
    /// @param _expires The time the verification expires
    function verifyCustomer(
        address _customer,
        bytes32 _jurisdiction,
        uint8 _role,
        bool _accredited,
        bytes32 _proof,
        uint256 _expires
    ) public onlyProvider
    {
        require(customers[msg.sender][_customer].verified == false);
        require(customers[msg.sender][_customer].role != 0);
        POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee);
        customers[msg.sender][_customer].jurisdiction = _jurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        customers[msg.sender][_customer].verified = true;
        NewCustomer(
            _customer,
            msg.sender,
            _jurisdiction,
            _role,
            _proof,
            true
        );
    }

    /// Getter function for attestations
    function getCustomer(address _provider, address _customer) public returns (
      bytes32 jurisdiction,
      bool accredited,
      uint8 role,
      bool verified,
      uint256 expires
    ) {
        Customer memory customer = customers[_provider][_customer];
        require(customer.verified);
        return (customer.jurisdiction, customer.accredited, customer.role, customer.verified, customer.expires);
    }

}

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/



contract Compliance {

    string public VERSION = "0.1";

    // A compliance template
    struct Template {
        address owner;
        string name;
        bytes32 issuerJurisdiction;
        mapping (bytes32 => bool) allowedJurisdictions;
        bool[] allowedRoles;
        bool accredited;
        bytes32 complianceProcess;
        uint256 finalizes;
        uint256 expires;
        uint256 fee;
    }

    // All compliance templates are stored in a mapping
    mapping(bytes32 => Template) templates;

    // Instance of the Compliance contract
    Customers public PolyCustomers;

    // Notifications
    event TemplateCreated(address creator, bytes32 _template, string _name);

    // Constructor
    /// @param _polyCustomersAddress The address of the Polymath Customers contract
    function Compliance(address _polyCustomersAddress) {
      PolyCustomers = Customers(_polyCustomersAddress);
    }

    /// `createTemplate` is a simple function to create a new compliance template
    /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
    /// @param _attestor The attestation provider to be used for the issuance
    /// @param _name The name of security being issued
    /// @param _issuerJurisdiction The jurisdiction id of the issuer
    /// @param _finalizes Timestamp of when the template will finalize and become non-editable
    /// @param _expires Timestamp of when the template will expire
    /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
    function createTemplate(
        bytes32 _template,
        string _name,
        address _attestor,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        uint256 _finalizes,
        uint256 _expires,
        uint256 _fee
    ) public
    {
        var (,, role, verified, expires) = PolyCustomers.getCustomer(_attestor, msg.sender);
        require(verified);
        require(role == 2);
        require(expires > now);
        require(templates[_template].owner == address(0));
        require(_finalizes > now);
        require(_expires >= _finalizes);
        templates[_template].owner = msg.sender;
        templates[_template].issuerJurisdiction = _issuerJurisdiction;
        templates[_template].name = _name;
        templates[_template].fee = _fee;
        templates[_template].accredited = _accredited;
        templates[_template].finalizes = _finalizes;
        templates[_template].expires = 0;
        TemplateCreated(msg.sender, _template, _name);
    }

    /// @notice `addJurisdictionToTemplate`allows the adding of new
    ///  jurisdictions to a template
    /// @param _template A SHA256 hash of the JSON schema containing full
    ///  compliance process/requirements
    /// @param _allowedJurisdictions An array of jurisdictions
    /// @param _allowed An array of whether the jurisdiction is allowed to
    ///  purchase the security or not
    function addJurisdictionToTemplate(bytes32 _template, bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(templates[_template].owner == msg.sender);
        require(templates[_template].finalizes > now);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            templates[_template].allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /// @notice `addRoleToTemplate` allows the adding of new roles to be added to whitelist
    /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
    /// @param _allowedRoles User roles that can purchase the security
    function addRolesToTemplate(bytes32 _template, uint8[] _allowedRoles) public {
        require(templates[_template].owner == msg.sender);
        require(templates[_template].finalizes > now);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            templates[_template].allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /// `finalizeTemplate` is used to finalize template.
    /// @param _template A SHA256 hash of the JSON schema containing
    ///  full compliance process/requirements
    function finalizeTemplate(bytes32 _template) public {
        require(templates[_template].owner == msg.sender);
        require(templates[_template].finalizes > now);
        templates[_template].finalizes = now;
    }

    /// `checkTemplateRequirements` is a constant function that
    ///  checks if templates requirements are met
    /// @param _template A SHA256 hash of the JSON schema containing full
    ///  compliance process/requirements
    /// @param _jurisdiction The ISO-3166 code of the investors jurisdiction
    /// @param _accredited Whether the investor is accredited or not
    function checkTemplateRequirements(
        bytes32 _template,
        bytes32 _jurisdiction,
        bool _accredited,
        uint8 _role
    ) public constant returns (bool allowed)
    {
        require(_template != 0 && _jurisdiction != 0);
        require(templates[_template].allowedJurisdictions[_jurisdiction] == true);
        require(templates[_template].allowedRoles[_role] == true);
        if (templates[_template].accredited == true) {
            require(_accredited == true);
        }
        return true;
    }

}