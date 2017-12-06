pragma solidity ^0.4.15;

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

contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerCandidate() {
        require(msg.sender == newOwnerCandidate);
        _;
    }

    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
        require(_newOwnerCandidate != address(0));
        newOwnerCandidate = _newOwnerCandidate;
        OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    function acceptOwnership() external onlyOwnerCandidate {
        address previousOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);
        OwnershipTransferred(previousOwner, owner);
    }
}

interface ISTRegistrar {

    // Creates a new Security Token and saves it to the registry
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    /// @param _type Type of security being tokenized
    function createSecurityToken (
        string _name,
        bytes8 _ticker,
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


    /// @notice This is a basic getter function to allow access to the
    ///  creator of a given STO contract through an interface.
    /// @param _contractAddress An STO contract
    /// @return address The address of the STO contracts creator
    function getCreator(address _contractAddress) public returns(address);

    /// @notice This is a basic getter function to allow access to the
    ///  fee of a given STO contract through an interface.
    /// @param _contractAddress An STO contract
    /// @return address The address of the STO contracts fee
    function getFee(address _contractAddress) public returns(uint256);
}

interface ISTO {

    // Initializes the STO with certain params
    /// @param _tokenAddress The Security Token address
    /// @param _startTime Given in UNIX time this is the time that the offering will begin
    /// @param _endTime Given in UNIX time this is the time that the offering will end
    function SecurityTokenOffering(
        address _tokenAddress,
        uint256 _startTime,
        uint256 _endTime
    ) external;

}

contract SecurityToken is IERC20, Ownable {

    using SafeMath for uint256;

    string public version = "0.1";

    // Legal delegate
    address public delegate;

    // Delegate Bids
    struct Bid {
        bytes32 template;
        uint256 fee;
        uint256 expires;
        uint32 quorum;
        uint256 vestingPeriod;
        address attestor;
    }
    mapping(address => Bid) public bids;

    // Template
    bytes32 public template;

    // Proof of process
    bytes32 public complianceProof;

    // STO address
    ISTO public STO;

    // Attestation provider
    address public attestor;

    // Security token shareholders
    mapping(address => bool) public shareholders;

    // Instance of the POLY token contract
    PolyToken public POLY;

    // Instance of the Security Token Registrar interface
    ISTRegistrar public SecurityTokenRegistrar;

    // Instance of the Compliance contract
    Compliance public PolyCompliance;

    // Instance of the Customers contract
    Customers PolyCustomers;

    // ERC20 Fields
    string public name;
    uint8 public decimals;
    bytes8 public symbol;
    address public owner;
    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    // Bounty allocations
    mapping(address => uint256) allocations;

    // Bounty voting
    struct Vote {
        bool hasVoted;
        bool vote;
    }

		// Values for the start and end time of the STO
    uint256 public issuanceStartTime;
    uint256 public issuanceEndTime;

    // The period which ST holders can vote to freeze the bounty
    uint256 public bountyVestingPeriod;

		// Tally values for Bounty voting
    uint256 public yay;
    uint256 public yayPercent;
    bool public freezeBounty;
    mapping (address => Vote) votes;

		// Variables for issuance status
    mapping (address => uint256) issuanceEndBalances;
		mapping (address => bool) issuancePaidOut;
		uint securityTokensIssued = 0;

    // Notifications
    event LogDelegateBid(address indexed _delegateAddress, uint256 _bid);
    event LogDelegateSet(address indexed _delegateAddress);
    event LogUpdatedComplianceProof(bytes32 merkleRoot, bytes32 _complianceProofHash);
    event LogSetAttestor(address indexed _attestor);
    event LogSetSTOContract(address indexed _STOAddress);

    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    modifier onlyDelegate() {
        require (msg.sender == delegate);
        _;
    }

    modifier onlyOwnerOrDelegate() {
        require (msg.sender == delegate || msg.sender == owner);
        _;
    }

		modifier onlySTO() {
			require (msg.sender == address(STO));
			_;
		}

    modifier onlyShareholder(address _shareholder) {
        require (shareholders[_shareholder] == true);
        _;
    }

    /// Set default security token parameters
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum address of the security token owner
    /// @param _template Hash of the compliance template
    /// @param _polyTokenAddress Ethereum address of the POLY token contract
    /// @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
    /// @param _polyComplianceAddress Ethereum address of the PolyCompliance contract
    /// @param _polySecurityTokenRegistrar Security Token Registrar address
    function SecurityToken(
        string _name,
        bytes8 _ticker,
        uint256 _totalSupply,
        address _owner,
        bytes32 _template,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress,
        address _polySecurityTokenRegistrar
    ) public
    {
        owner = _owner;
        name = _name;
        symbol = _ticker;
        decimals = 0;
        template = _template;
        totalSupply = _totalSupply;
        balances[_owner] = _totalSupply;
        POLY = PolyToken(_polyTokenAddress);
        PolyCustomers = Customers(_polyCustomersAddress);
        PolyCompliance = Compliance(_polyComplianceAddress);
        SecurityTokenRegistrar = ISTRegistrar(_polySecurityTokenRegistrar);
    }

    /// Make a new bid to be the legal delegate
    /// @param _fee The bounty fee requested to become legal delegate
    /// @param _expires The timestamp the bid expires at
    /// @param _quorum The percentage of initial shareholders required to freeze bounty funds
    /// @param _vestingPeriod The period of time shareholders can freeze bounty funds
    /// @return bool success
    function makeBid(
        bytes32 _template,
        uint256 _fee,
        uint256 _expires,
        uint32 _quorum,
        uint256 _vestingPeriod,
        address _attestor
    ) public returns (bool success)
    {
        var (,, role, verified, expires) = PolyCustomers.getCustomer(_attestor, msg.sender);
        require(verified == true);
        require(role == 2);
        require(expires > now);
        require(_expires >= now);
        require(_fee > 0);
        require(_vestingPeriod >= 7777777);
        bids[msg.sender] = Bid({template: _template, fee: _fee, expires: _expires, quorum: _quorum, vestingPeriod: _vestingPeriod, attestor: _attestor});
        return true;
    }

    /// Accept a Delegate's bid
    /// @param _delegate Legal Delegates public ethereum address
    /// @return bool success
    function setDelegate(address _delegate) public onlyOwner returns (bool success) {
        require(_delegate == address(0));
        require(bids[_delegate].expires > now);
        require(POLY.balanceOf(this) >= bids[_delegate].fee);
        delegate = _delegate;
        allocations[_delegate] = bids[_delegate].fee;
        LogDelegateSet(_delegate);
        return true;
    }

    /// Update compliance Proof
    /// @param _newMerkleRoot New merkle root hash of the compliance Proofs
    /// @param _complianceProof Compliance Proof hash
    /// @return bool success
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public onlyOwnerOrDelegate returns (bool success) {
        require(msg.sender == owner || msg.sender == delegate);
        complianceProof = _newMerkleRoot;
        LogUpdatedComplianceProof(_newMerkleRoot, _complianceProof);
        return true;
    }

    /// Set the STO contract address
    /// @param _securityTokenOfferingAddress Ethereum address of the STO contract
    /// @return bool success
    function setSTOContract (
        address _securityTokenOfferingAddress,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyDelegate returns (bool success) {
        require(_securityTokenOfferingAddress != address(0));
        require(complianceProof != 0);
        uint256 fee = SecurityTokenRegistrar.getFee(_securityTokenOfferingAddress);
        address developer = SecurityTokenRegistrar.getCreator(_securityTokenOfferingAddress);
        require(POLY.balanceOf(this) >= fee + allocations[msg.sender]);
        allocations[developer] = fee;
        STO = ISTO(_securityTokenOfferingAddress);
        issuanceEndTime = _endTime;
        LogSetSTOContract(_securityTokenOfferingAddress);
        return true;
    }

    /// Add a verified address to the Security Token whitelist
    /// @param _shareholderAddress Address attempting to join ST whitelist
    /// @return bool success
    function addToWhitelist(address _shareholderAddress) public returns (bool success) {
        require(attestor != address(0));
        require(template != 0);
        var (jurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(bids[delegate].attestor, msg.sender);
        require(verified && expires > now);
        bool requirementsMet = PolyCompliance.checkTemplateRequirements(template, jurisdiction, accredited, role);
        require(requirementsMet);
        shareholders[_shareholderAddress] = true;
        return true;
    }

    /// Allow the bounty to be withdrawn by owner, delegate, and the STO developer at appropriate times
    /// @param _amount Amount of POLY being withdrawn from the bounty
    /// @return bool success
    function withdrawBounty(uint256 _amount) public returns (bool success) {
			if (delegate == address(0)) {
        return POLY.transfer(owner, _amount);
      } else {
				require(now > issuanceEndTime + bids[delegate].vestingPeriod);
        require(freezeBounty == false);
        require(allocations[msg.sender] >= _amount);
				require(POLY.transfer(msg.sender, _amount));
        allocations[msg.sender] = allocations[msg.sender].sub(_amount);
        return true;
      }
    }

    /// Vote to freeze the compliance bounty fund
    /// @param _freezeVote `true` will vote to freeze, `false` will do nothing.
    /// @return bool success
    function voteToFreeze(bool _freezeVote) public returns (bool success) {
      require(delegate != address(0));
      require(now > issuanceEndTime);
      require(now < issuanceEndTime + bountyVestingPeriod);
      require(votes[msg.sender].hasVoted == false);
      if (_freezeVote) {
        yay = yay + issuanceEndBalances[msg.sender];
        yayPercent = yay.mul(100).div(totalSupply);
        if (yayPercent > bids[delegate].quorum) {
          freezeBounty = true;
        }
      }
      votes[msg.sender] = Vote({ hasVoted: true, vote: _freezeVote });
      return true;
    }

		/// @notice `issueSecurityTokens` is used by the STO to issue ST's to shareholders
		///  at the end of the issuance.
		/// @param _contributor The address of the person whose contributing
		/// @param _amount The amount of ST to pay out.
		function issueSecurityTokens(address _contributor, uint256 _amount) public onlySTO {
			require(issuanceEndTime > now);
			require(securityTokensIssued.add(_amount) <= balanceOf(this));
			securityTokensIssued = securityTokensIssued.add(_amount);
			issuanceEndBalances[_contributor] = issuanceEndBalances[_contributor].add(_amount);
		}

		/// @notice `collectIssuance` is used to collect ST tokens
		///  after the issuance period has passed.
		function collectIssuance() public {
			require(now > issuanceEndTime);
			require(issuanceEndBalances[msg.sender] != 0);
			require(transfer(msg.sender, issuanceEndBalances[msg.sender]));
		}

    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to] && balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /// Allows contracts to transfer tokens on behalf of token holders
    /// @param _from Address to transfer tokens from
    /// @param _to Address to send tokens to
    /// @param _value Number of tokens to transfer
    /// @return bool success
    /// TODO: eliminate msg.sender for 0x
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to] && shareholders[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            uint256 _allowance = allowed[_from][msg.sender];
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            allowed[_from][msg.sender] = _allowance.sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// Approve transfer of tokens manually
    /// @param _spender Address to approve transfer to
    /// @param _value Amount of tokens to approve for transfer
    /// @return bool success
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (shareholders[_spender]) {
            // @dev the logic on this looks screwey. Worth a look in testing
            require ((_value != 0) && (allowed[msg.sender][_spender] != 0));
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        } else {
            return false;
        }
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

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
        address tokenAddress;
        uint8 securityType;
    }

    // Mapping of ticker name to Security Token details
    mapping(bytes8 => SecurityTokenData) securityTokenRegistrar;

    // Security Token Offering Contract
    struct SecurityTokenOfferingContract {
        address creator;
        uint256 fee;
    }

    // Mapping of contract address to contract details
    mapping(address => SecurityTokenOfferingContract) public securityTokenOfferingContracts;

    event LogNewSecurityToken(bytes8 indexed ticker, address securityTokenAddress, address owner);
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
    function createSecurityToken (string _name, bytes8 _ticker, uint256 _totalSupply, address _owner, bytes32 _template, uint8 _type) external {
      //TODO require(securityTokenRegistrar[_ticker] != address(0));

      // Collect creation fee
      PolyToken(polyTokenAddress).transferFrom(_owner, this, 1000);

      // Create the new Security Token contract
      address newSecurityTokenAddress = new SecurityToken(_name, _ticker, _totalSupply, _owner, _template, polyTokenAddress, polyCustomersAddress, polyComplianceAddress, this);

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
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, _owner);
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
    /// @return creator The address of the STO contracts creator
    function getCreator(address _contractAddress) public returns(address creator) {
        return securityTokenOfferingContracts[_contractAddress].creator;
    }

    /// @notice This is a basic getter function to allow access to the
    ///  fee of a given STO contract through an interface.
    /// @param _contractAddress An STO contract
    /// @return fee The fee paid to the developer of the STO
    function getFee(address _contractAddress) public returns(uint256 fee) {
        return securityTokenOfferingContracts[_contractAddress].fee;
    }

}