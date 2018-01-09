pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

interface ICompliance {

    /* @dev `createTemplate` is a simple function to create a new compliance template
    @param _offeringType The name of the security being issued
    @param _issuerJurisdiction The jurisdiction id of the issuer
    @param _accredited Accreditation status required for investors
    @param _KYC KYC provider used by the template
    @param _details Details of the offering requirements
    @param _expires Timestamp of when the template will expire
    @param _fee Amount of POLY to use the template (held in escrow until issuance)
    @param _quorum Minimum percent of shareholders which need to vote to freeze
    @param _vestingPeriod Length of time to vest funds */
    function createTemplate(
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public;

    /* @dev Propose a bid for a security token issuance
    @param _securityToken The security token being bid on
    @param _template The unique template address
    @return bool success */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success);

    /* @dev Propose a Security Token Offering Contract for an issuance
    @param _securityToken The security token being bid on
    @param _stoContract The security token offering contract address
    @return bool success */
    function proposeOfferingContract(
        address _securityToken,
        address _stoContract
    ) public returns (bool success);

    /* @dev Cancel a Template proposal if the bid hasn't been accepted
    @param _securityToken The security token being bid on
    @param _templateProposalIndex The template proposal array index
    @return bool success */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success);

    /* @dev Set the STO contract by the issuer.
       @param _STOAddress address of the STO contract deployed over the network.
       @param _fee fee to be paid in poly to use that contract
       @param _vestingPeriod no. of days investor binded to hold the Security token
       @param _quorum Minimum percent of shareholders which need to vote to freeze*/
    function setSTO (
        address _STOAddress,
        uint256 _fee,
        uint256 _vestingPeriod,
        uint8 _quorum
    ) public returns (bool success);

    /* @dev Cancel a STO contract proposal if the bid hasn't been accepted
    @param _securityToken The security token being bid on
    @param _offeringProposalIndex The offering proposal array index
    @return bool success */
    function cancelOfferingProposal(
        address _securityToken,
        uint256 _offeringProposalIndex
    ) public returns (bool success);

    /* @dev `updateTemplateReputation` is a constant function that updates the
     history of a security token template usage to keep track of previous uses
    @param _template The unique template id
    @param _templateIndex The array index of the template proposal */
    function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success);

    /* @dev `updateOfferingReputation` is a constant function that updates the
     history of a security token offering contract to keep track of previous uses
    @param _contractAddress The smart contract address of the STO contract
    @param _offeringProposalIndex The array index of the security token offering proposal */
    function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success);

    /* @dev Get template details by the proposal index
    @param _securityTokenAddress The security token ethereum address
    @param _templateIndex The array index of the template being checked
    @return Template struct */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address template
    );

    /* @dev Get security token offering smart contract details by the proposal index
    @param _securityTokenAddress The security token ethereum address
    @param _offeringProposalIndex The array index of the STO contract being checked
    @return Contract struct */
    function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
        address stoContract,
        address auditor,
        uint256 vestingPeriod,
        uint8 quorum,
        uint256 fee
    );
}

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
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

/*
 POLY token faucet is only used on testnet for testing purposes
 !!!! NOT INTENDED TO BE USED ON MAINNET !!!
*/




contract PolyToken is IERC20 {

    using SafeMath for uint256;
    uint256 public totalSupply = 1000000;
    string public name = "Polymath Network";
    uint8 public decimals = 18;
    string public symbol = "POLY";

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Token faucet - Not part of the ERC20 standard */
    function getTokens(uint256 _amount, address _recipient) public returns (bool) {
        balances[_recipient] += _amount;
        totalSupply += _amount;
        return true;
    }

    /* @dev send `_value` token to `_to` from `msg.sender`
    @param _to The address of the recipient
    @param _value The amount of token to be transferred
    @return Whether the transfer was successful or not */
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /* @dev send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
      @param _from The address of the sender
      @param _to The address of the recipient
      @param _value The amount of token to be transferred
      @return Whether the transfer was successful or not */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      require(_to != address(0));
      require(_value <= balances[_from]);
      require(_value <= allowed[_from][msg.sender]);

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
      Transfer(_from, _to, _value);
      return true;
    }

    /* @param _owner The address from which the balance will be retrieved
    @return The balance */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* @dev `msg.sender` approves `_spender` to spend `_value` tokens
    @param _spender The address of the account able to transfer the tokens
    @param _value The amount of tokens to be approved for transfer
    @return Whether the approval was successful or not */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /* @param _owner The address of the account owning tokens
    @param _spender The address of the account able to transfer the tokens
    @return Amount of remaining tokens allowed to spent */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

interface ICustomers {

  /* @dev Allow new provider applications
  @param _providerAddress The provider's public key address
  @param _name The provider's name
  @param _details A SHA256 hash of the new providers details
  @param _fee The fee charged for customer verification */
  function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);

  /* @dev Change a providers fee
  @param _newFee The new fee of the provider */
  function changeFee(uint256 _newFee) public returns (bool success);

  /* @dev Verify an investor
  @param _customer The customer's public key address
  @param _jurisdiction The jurisdiction code of the customer
  @param _role The type of customer - investor:1, issuer:2, delegate:3, marketmaker:4, etc.
  @param _accredited Whether the customer is accredited or not (only applied to investors)
  @param _expires The time the verification expires */
  function verifyCustomer(
    address _customer,
    bytes32 _jurisdiction,
    uint8 _role,
    bool _accredited,
    uint256 _expires
  ) public returns (bool success);

  // Get customer attestation data by KYC provider and customer ethereum address
  function getCustomer(address _provider, address _customer) public constant returns (
    bytes32,
    bool,
    uint8,
    bool,
    uint256
  );

  // Get provider details and fee by ethereum address
  function getProvider(address _providerAddress) public constant returns (
    string name,
    uint256 joined,
    bytes32 details,
    uint256 fee
  );
}

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by providers.
*/




contract Customers is ICustomers {

    PolyToken POLY;

    uint256 public constant newProviderFee = 1000;

    // A Customer
    struct Customer {
        bytes32 jurisdiction;
        uint256 joined;
        uint8 role;
        bool verified;
        bool accredited;
        bytes32 proof;
        uint256 expires;
    }

    // Customers (kyc provider address => customer address)
    mapping(address => mapping(address => Customer)) public customers;

    // KYC/Accreditation Provider
    struct Provider {
        string name;
        uint256 joined;
        bytes32 details;
        uint256 fee;
    }

    // KYC/Accreditation Providers
    mapping(address => Provider) public providers;

    // Notifications
    event LogNewProvider(address providerAddress, string name, bytes32 details);
    event LogCustomerVerified(address customer, address provider, uint8 role);

    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    // Constructor
    function Customers(address _polyTokenAddress) public {
        POLY = PolyToken(_polyTokenAddress);
    }

    /* @dev Allow new provider applications
    @param _providerAddress The provider's public key address
    @param _name The provider's name
    @param _details A SHA256 hash of the new providers details
    @param _fee The fee charged for customer verification */
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
        require(_providerAddress != address(0));
        require(_details != 0x0);
        require(providers[_providerAddress].details == 0);
        require(POLY.transferFrom(_providerAddress, address(this), newProviderFee));
        providers[_providerAddress] = Provider(_name, now, _details, _fee);
        LogNewProvider(_providerAddress, _name, _details);
        return true;
    }

    /* @dev Change a providers fee
    @param _newFee The new fee of the provider */
    function changeFee(uint256 _newFee) public returns (bool success) {
        require(providers[msg.sender].details != 0);
        providers[msg.sender].fee = _newFee;
        return true;
    }

    /* @dev Verify an investor
    @param _customer The customer's public key address
    @param _jurisdiction The jurisdiction code of the customer
    @param _role The type of customer - investor:1, issuer:2, delegate:3, marketmaker:4, etc.
    @param _accredited Whether the customer is accredited or not (only applied to investors)
    @param _expires The time the verification expires */
    function verifyCustomer(
        address _customer,
        bytes32 _jurisdiction,
        uint8 _role,
        bool _accredited,
        uint256 _expires
    ) public onlyProvider returns (bool success)
    {
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].jurisdiction = _jurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        customers[msg.sender][_customer].verified = true;
        LogCustomerVerified(_customer, msg.sender, _role);
        return true;
    }

    // Get customer attestation data by KYC provider and customer ethereum address
    function getCustomer(address _provider, address _customer) public constant returns (
        bytes32,
        bool,
        uint8,
        bool,
        uint256
    ) {
      return (
        customers[_provider][_customer].jurisdiction,
        customers[_provider][_customer].accredited,
        customers[_provider][_customer].role,
        customers[_provider][_customer].verified,
        customers[_provider][_customer].expires
      );
    }

    // Get provider details and fee by ethereum address
    function getProvider(address _providerAddress) public constant returns (
        string name,
        uint256 joined,
        bytes32 details,
        uint256 fee
    ) {
      return (
        providers[_providerAddress].name,
        providers[_providerAddress].joined,
        providers[_providerAddress].details,
        providers[_providerAddress].fee
      );
    }

}

interface ITemplate {

  /* @dev `addJurisdiction` allows the adding of new jurisdictions to a template
  @param _allowedJurisdictions An array of jurisdictions
  @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /* @dev `addRole` allows the adding of new roles to be added to whitelist
  @param _allowedRoles User roles that can purchase the security */
  function addRoles(uint8[] _allowedRoles) public;

  /// @notice `updateDetails`
  function updateDetails(bytes32 _details) public returns (bool allowed);

  /* @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements */
  function finalizeTemplate() public returns (bool success);

  /* @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
  @param _jurisdiction The ISO-3166 code of the investors jurisdiction
  @param _accredited Whether the investor is accredited or not */
  function checkTemplateRequirements(
      bytes32 _jurisdiction,
      bool _accredited,
      uint8 _role
  ) public constant returns (bool allowed);

  /* getTemplateDetails is a constant function that gets template details
  @return bytes32 details, bool finalized */
  function getTemplateDetails() view public returns (bytes32, bool);

  /// `getUsageFees` is a function to get all the details on template usage fees
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);
}

/*
  Polymath compliance template is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  template allows security tokens to enforce purchase restrictions on chain and
  keep a log of documents for future auditing purposes.
*/



contract Template is ITemplate {

    address owner;
    string offeringType;
    bytes32 issuerJurisdiction;
    mapping(bytes32 => bool) allowedJurisdictions;
    bool[] allowedRoles;
    bool accredited;
    address KYC;
    bytes32 details;
    bool finalized;
    uint256 expires;
    uint256 fee;
    uint8 quorum;
    uint256 vestingPeriod;

    function Template (
        address _owner,
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public
    {
        owner = _owner;
        offeringType = _offeringType;
        issuerJurisdiction = _issuerJurisdiction;
        accredited = _accredited;
        KYC = _KYC;
        details = _details;
        finalized = false;
        expires = _expires;
        fee = _fee;
        quorum = _quorum;
        vestingPeriod = _vestingPeriod;
    }

    /* @dev `addJurisdiction` allows the adding of new jurisdictions to a template
    @param _allowedJurisdictions An array of jurisdictions
    @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not */
    function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(owner == msg.sender);
        require(_allowedJurisdictions.length == _allowed.length);
        require(!finalized);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /* @dev `addRole` allows the adding of new roles to be added to whitelist
    @param _allowedRoles User roles that can purchase the security */
    function addRoles(uint8[] _allowedRoles) public {
        require(owner == msg.sender);
        require(!finalized);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /// @notice `updateDetails`
    function updateDetails(bytes32 _details) public returns (bool allowed) {
        require(_details != 0x0);
        require(owner == msg.sender);
        details = _details;
        return true;
    }

    /* @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements */
    function finalizeTemplate() public returns (bool success) {
        require(owner == msg.sender);
        finalized = true;
        return true;
    }

    /* @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
    @param _jurisdiction The ISO-3166 code of the investors jurisdiction
    @param _accredited Whether the investor is accredited or not */
    function checkTemplateRequirements(
        bytes32 _jurisdiction,
        bool _accredited,
        uint8 _role
    ) public constant returns (bool allowed)
    {
        require(_jurisdiction != 0x0);
        require(allowedJurisdictions[_jurisdiction] == true);
        require(allowedRoles[_role] == true);
        if (accredited == true) {
            require(_accredited == true);
        }
        return true;
    }

    /* getTemplateDetails is a constant function that gets template details
    @return bytes32 details, bool finalized */
    function getTemplateDetails() view public returns (bytes32, bool) {
        require(expires > now);
        return (details, finalized);
    }

    /// `getUsageFees` is a function to get all the details on template usage fees
    function getUsageDetails() view public returns (uint256, uint8, uint256, address, address) {
        return (fee, quorum, vestingPeriod, owner, KYC);
    }
}

interface ISecurityToken {

    /* @dev Set default security token parameters
    @param _name Name of the security token
    @param _ticker Ticker name of the security
    @param _totalSupply Total amount of tokens being created
    @param _owner Ethereum address of the security token owner
    @param _maxPoly Amount of POLY being raised
    @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    @param _quorum Percent of initial investors required to freeze POLY raise
    @param _polyTokenAddress Ethereum address of the POLY token contract
    @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
    @param _polyComplianceAddress Ethereum address of the PolyCompliance contract */
    function SecurityToken(
        string _name,
        string _ticker,
        uint256 _totalSupply,
        address _owner,
        uint256 _maxPoly,
        uint256 _lockupPeriod,
        uint8 _quorum,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public;

    /* @dev `selectTemplate` Select a proposed template for the issuance
    @param _templateIndex Array index of the delegates proposed template
    @return bool success */
    function selectTemplate(uint8 _templateIndex) public returns (bool success);

    /* @dev Update compliance proof hash for the issuance
    @param _newMerkleRoot New merkle root hash of the compliance Proofs
    @param _complianceProof Compliance Proof hash
    @return bool success */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public returns (bool success);

    /* @dev Select an security token offering proposal for the issuance
    @param _offeringProposalIndex Array index of the STO proposal
    @param _startTime Start of issuance period
    @param _endTime End of issuance period
    @return bool success */
    function selectOfferingProposal (
        uint8 _offeringProposalIndex,
        uint256 _startTime,
        uint256 _endTime
    ) public returns (bool success);

    /* @dev Add a verified address to the Security Token whitelist
    @param _whitelistAddress Address attempting to join ST whitelist
    @return bool success */
    function addToWhitelist(uint8 KYCProviderIndex, address _whitelistAddress) public returns (bool success);

    /* @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO developer at appropriate times
    @return bool success */
    function withdrawPoly() public returns (bool success);

    /* @dev Vote to freeze the fee of a certain network participant
    @param _recipient The fee recipient being protested
    @return bool success */
    function voteToFreeze(address _recipient) public returns (bool success);

    /* @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
    @param _contributor The address of the person whose contributing
    @param _amountOfSecurityTokens The amount of ST to pay out.
    @param _polyContributed The amount of POLY paid for the security tokens. */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public returns (bool success);

    /// Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address);

    /* @dev Trasfer tokens from one address to another
    @param _to Ethereum public address to transfer tokens to
    @param _value Amount of tokens to send
    @return bool success */
    function transfer(address _to, uint256 _value) public returns (bool success);

    /* @dev Allows contracts to transfer tokens on behalf of token holders
    @param _from Address to transfer tokens from
    @param _to Address to send tokens to
    @param _value Number of tokens to transfer
    @return bool success */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /* @param _owner The address from which the balance will be retrieved
    @return The balance */
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /* @dev Approve transfer of tokens manually
    @param _spender Address to approve transfer to
    @param _value Amount of tokens to approve for transfer
    @return bool success */
    function approve(address _spender, uint256 _value) public returns (bool success);

    /* @param _owner The address of the account owning tokens
    @param _spender The address of the account able to transfer the tokens
    @return Amount of remaining tokens allowed to spent */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  }

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/






contract Compliance is ICompliance {

    string public VERSION = "0.1";

    // A compliance template
    struct TemplateReputation {
        address owner;
        uint256 totalRaised;
        uint256 timesUsed;
        uint256 expires;
        address[] usedBy;
    }
    mapping(address => TemplateReputation) templates;

    // Template proposals for a specific security token
    mapping(address => address[]) public templateProposals;

    // Smart contract proposals for a specific security token offering
    struct Offering {
        address auditor;
        uint256 fee;
        uint256 vestingPeriod;
        uint8 quorum;
        address[] usedBy;
    }
    mapping(address => Offering) offerings;
    // Security token contract proposals for a specific security token
    mapping(address => address[]) public offeringProposals;

    // Instance of the Compliance contract
    Customers public PolyCustomers;

    // 100 Day minimum vesting period for POLY earned
    uint256 public constant minimumVestingPeriod = 60 * 60 * 24 * 100;

    // Notifications
    event LogTemplateCreated(address indexed creator, address _template, string _offeringType);
    event LogNewTemplateProposal(address indexed _securityToken, address _template, address _delegate);
    event LogNewContractProposal(address indexed _securityToken, address _offeringContract, address _delegate);
    
    /* @param _polyCustomersAddress The address of the Polymath Customers contract */
    function Compliance(address _polyCustomersAddress) public {
        PolyCustomers = Customers(_polyCustomersAddress);
    }

    /* @dev `createTemplate` is a simple function to create a new compliance template
    @param _offeringType The name of the security being issued
    @param _issuerJurisdiction The jurisdiction id of the issuer
    @param _accredited Accreditation status required for investors
    @param _KYC KYC provider used by the template
    @param _details Details of the offering requirements
    @param _expires Timestamp of when the template will expire
    @param _fee Amount of POLY to use the template (held in escrow until issuance)
    @param _quorum Minimum percent of shareholders which need to vote to freeze
    @param _vestingPeriod Length of time to vest funds */
    function createTemplate(
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public
    {
        var (,, role, verified, expires) = PolyCustomers.getCustomer(_KYC, msg.sender);
        require(role == 2 && verified && expires > now);
        require(_quorum > 0 && _quorum < 100);
        require(_vestingPeriod >= minimumVestingPeriod);
        address _template = new Template(
            msg.sender,
            _offeringType,
            _issuerJurisdiction,
            _accredited,
            _KYC,
            _details,
            _expires,
            _fee,
            _quorum,
            _vestingPeriod
        );
        templates[_template] = TemplateReputation({
            owner: msg.sender,
            totalRaised: 0,
            timesUsed: 0,
            expires: _expires,
            usedBy: new address[](0)
        });
        LogTemplateCreated(msg.sender, _template, _offeringType);
    }

    /* @dev Propose a bid for a security token issuance
    @param _securityToken The security token being bid on
    @param _template The unique template address
    @return bool success */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success)
    {
        require(templates[_template].expires > now);
        require(templates[_template].owner == msg.sender);
        templateProposals[_securityToken].push(_template);
        LogNewTemplateProposal(_securityToken, _template, msg.sender);
        return true;
    }

    /* @dev Cancel a Template proposal if the bid hasn't been accepted
    @param _securityToken The security token being bid on
    @param _templateProposalIndex The template proposal array index
    @return bool success */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success)
    {
        address proposedTemplate = templateProposals[_securityToken][_templateProposalIndex];
        require(templates[proposedTemplate].owner == msg.sender);
        var (chosenTemplate,,,,) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenTemplate != proposedTemplate);
        templateProposals[_securityToken][_templateProposalIndex] = address(0);
        return true;
    }

    /* @dev Set the STO contract by the issuer.
       @param _STOAddress address of the STO contract deployed over the network.
       @param _fee fee to be paid in poly to use that contract
       @param _vestingPeriod no. of days investor binded to hold the Security token
       @param _quorum Minimum percent of shareholders which need to vote to freeze*/
    function setSTO (
        address _STOAddress,
        uint256 _fee,
        uint256 _vestingPeriod,
        uint8 _quorum
        ) public returns (bool success)
    {
            require(_STOAddress != address(0));
            require(_quorum > 0 && _quorum < 100);
            require(_vestingPeriod >= minimumVestingPeriod);
            offerings[_STOAddress].auditor = msg.sender;
            offerings[_STOAddress].fee = _fee;
            offerings[_STOAddress].vestingPeriod = _vestingPeriod;
            offerings[_STOAddress].quorum = _quorum;
            return true;
    }

    /* @dev Propose a Security Token Offering Contract for an issuance
    @param _securityToken The security token being bid on
    @param _stoContract The security token offering contract address
    @return bool success */
    function proposeOfferingContract(
        address _securityToken,
        address _stoContract
    ) public returns (bool success)
    {
        var (,,,,KYC) = ISecurityToken(_securityToken).getTokenDetails();
        var (,,, verified, expires) = PolyCustomers.getCustomer(KYC, offerings[_stoContract].auditor);
        require(offerings[_stoContract].auditor == msg.sender);
        require(verified == true);
        require(expires > now);
        offeringProposals[_securityToken].push(_stoContract);
        LogNewContractProposal(_securityToken, _stoContract, msg.sender);
        return true;
    }

    /* @dev Cancel a STO contract proposal if the bid hasn't been accepted
    @param _securityToken The security token being bid on
    @param _offeringProposalIndex The offering proposal array index
    @return bool success */
    function cancelOfferingProposal(
        address _securityToken,
        uint256 _offeringProposalIndex
    ) public returns (bool success)
    {
        address proposedOffering = offeringProposals[_securityToken][_offeringProposalIndex];
        require(offerings[proposedOffering].auditor == msg.sender);
        var (,,,,chosenOffering) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenOffering != proposedOffering);
        offeringProposals[_securityToken][_offeringProposalIndex] = address(0);
        return true;
    }

    /* @dev `updateTemplateReputation` is a constant function that updates the
     history of a security token template usage to keep track of previous uses
    @param _template The unique template id
    @param _templateIndex The array index of the template proposal */
    function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success) {
        require(templateProposals[msg.sender][_templateIndex] == _template);
        templates[_template].usedBy.push(msg.sender);
        return true;
    }

    /* @dev `updateOfferingReputation` is a constant function that updates the
     history of a security token offering contract to keep track of previous uses
    @param _contractAddress The smart contract address of the STO contract
    @param _offeringProposalIndex The array index of the security token offering proposal */
    function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success) {
        require(offeringProposals[msg.sender][_offeringProposalIndex] == _stoContract);
        offerings[_stoContract].usedBy.push(msg.sender);
        return true;
    }

    /* @dev Get template details by the proposal index
    @param _securityTokenAddress The security token ethereum address
    @param _templateIndex The array index of the template being checked
    @return Template struct */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address template
    ){
        return templateProposals[_securityTokenAddress][_templateIndex];
    }

    /* @dev Get security token offering smart contract details by the proposal index
    @param _securityTokenAddress The security token ethereum address
    @param _offeringProposalIndex The array index of the STO contract being checked
    @return Contract struct */
    function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
        address stoContract,
        address auditor,
        uint256 vestingPeriod,
        uint8 quorum,
        uint256 fee
    ){
        address _stoContract = offeringProposals[_securityTokenAddress][_offeringProposalIndex];
        return (
            _stoContract,
            offerings[_stoContract].auditor,
            offerings[_stoContract].vestingPeriod,
            offerings[_stoContract].quorum,
            offerings[_stoContract].fee
        );
    }

}