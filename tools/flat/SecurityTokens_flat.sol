pragma solidity ^0.4.15;
contract Ownable {
    address public owner;
    address public newOwnerCandidate;
    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);
    function Ownable() {
      owner = msg.sender;
    }
    modifier onlyOwner() {
      if (msg.sender != owner) {
        revert();
      }
      _;
    }
    modifier onlyOwnerCandidate() {
      if (msg.sender != newOwnerCandidate) {
        revert();
      }
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
/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
contract IERC20 {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
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
    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
      return a >= b ? a : b;
    }
    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
      return a < b ? a : b;
    }
    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
      return a >= b ? a : b;
    }
    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
      return a < b ? a : b;
    }
}
/// Basic ERC20 token contract implementation.
/// Based on OpenZeppelin's StandardToken.
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;
    /// Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    function approve(address _spender, uint256 _value) public returns (bool) {
      // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
      if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
        revert();
      }
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
    }
    /// Function to check the amount of tokens that an owner allowed to a spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    /// Gets the balance of the specified address.
    function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
    }
    /// Transfer token to a specified address.
    function transfer(address _to, uint256 _value) public returns (bool) {
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }
    /// Transfer tokens from one address to another.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      uint256 _allowance = allowed[_from][msg.sender];
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = _allowance.sub(_value);
      Transfer(_from, _to, _value);
      return true;
    }
}
// An ERC20 token standard faucet
contract PolyToken is ERC20 {
    uint256 public totalSupply = 1000000;
    string public name = 'Polymath Network';
    uint8 public decimals = 18;
    string public symbol = 'POLY';
    /* Token faucet - Not part of the ERC20 standard */
    function getTokens (uint256 _amount) {
      balances[msg.sender] += _amount;
      totalSupply += _amount;
    }
}
/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by KYC providers.
*/
contract Customers is Ownable {
  // A Polymath Customer
  struct Customer {
    bytes8 jurisdiction;
    uint8 role;
    bool verified;
    bool accredited;
    bool flagged;
    bytes32 proof;
    uint256 expires;
  }
  // Provider address => {customer address => Customer}
  mapping(address => mapping(address => Customer)) public customers;
  // KYC Provider
  struct Provider {
    string name;
    bytes32 application;
    bool approved;
    uint256 expires;
  }
  // Provider address => Provider
  mapping(address => Provider) public providers;
  // Notifications
  event NewCustomer(address customer, address provider, bytes32 jurisdiction, uint8 role, bytes32 proof, bool verified);
  event NewProvider(address providerAddress, string name, bytes32 application, bool approved);
  /// Allow new investor applications
  /// @param _jurisdiction The jurisdiction code of the customer
  /// @param _provider The provider selected by the customer to do verification
  /// @param _role The type of customer - investor:1 or issuer:2
  /// @param _proof The SHA256 hash of the documentation provided to prove identity
  function newCustomer(bytes8 _jurisdiction, address _provider, uint8 _role, bytes32 _proof) {
    require(providers[_provider].approved);
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
  /// @param _accredited Whether the customer is accredited or not (only applied to investors)
  /// @param _proof The SHA256 hash of the documentation provided to prove identity
  /// @param _expires The time the KYC verification expires
  function verifyCustomer(address _customer, bytes8 _jurisdiction, uint8 _role, bool _accredited, bytes32 _proof, uint256 _expires) {
    require(customers[msg.sender][_customer].verified == false);
    customers[msg.sender][_customer].jurisdiction = _jurisdiction;
    customers[msg.sender][_customer].role = _role;
    customers[msg.sender][_customer].accredited = _accredited;
    customers[msg.sender][_customer].expires = _expires;
    customers[msg.sender][_customer].verified = true;
    NewCustomer(_customer, msg.sender, _jurisdiction, _role, _proof, true);
  }
  /// Allow new provider applications
  /// @param _providerAddress The provider's public key address
  /// @param _name The provider's name
  /// @param _application A SHA256 hash of the application document
  function newProvider(address _providerAddress, string _name, bytes32 _application) {
    require(_providerAddress != address(0));
    // require(providers[_providerAddress] == 0);
    providers[_providerAddress].name = _name;
    providers[_providerAddress].application = _application;
    providers[_providerAddress].approved = false;
    NewProvider(_providerAddress, _name, _application, false);
  }
  /// Approve or reject a new provider application
  /// @param _providerAddress The provider's public key address
  /// @param _approved Is the provider approved or not
  /// @param _expires Timestamp the delegate is valid on Polymath until
  function approveProvider(address _providerAddress, bool _approved, uint256 _expires) onlyOwner {
    require(_expires >= now);
    if (_approved == true) {
      providers[_providerAddress].expires = _expires;
      providers[_providerAddress].approved = true;
      NewProvider(_providerAddress, providers[_providerAddress].name, providers[_providerAddress].application, true);
    } else {
      delete providers[_providerAddress];
    }
  }
}
contract SecurityToken is ERC20 {
    string public version = '0.1';
    // Compliance Template Proposal
    struct ComplianceTemplate {
      address creator;
      bytes32 securityType;
      bytes32 complianceProcess;
      bytes8 issuerJurisdiction;
      bytes8[] restrictedJurisdictions;
      uint256 templateValidUntil;
      uint256 proposalValidUntil;
      uint256 estimatedTimeToComplete;
      uint256 vestingPeriod;
      uint256 delegateFee;
    }
    // Mapping of Legal Delegate addresses to proposed ComplianceTemplates
    mapping(address => ComplianceTemplate) public complianceTemplateProposals;
    // Legal delegate
    address public delegate;
    // Proof of compliance process (merkle root hash)
    bytes32 public complianceProof;
    // STO address
    address public STO;
    // KYC Provider
    address public KYC;
    // Security Token Whitelisted Investors
    mapping(address => bool) public investors;
    // Instance of the POLY token contract
    PolyToken public POLY;
    Customers PolyCustomers;
    // Notifications
    event LogDelegateSet(address indexed delegateAddress);
    event LogComplianceTemplateProposal(address indexed delegateAddress, bytes32 complianceTemplate);
    event LogSecurityTokenOffering(address indexed STOAddress);
    event LogNewComplianceProof(bytes32 merkleRoot, bytes32 complianceProofHash);
    event LogSetKYC(address kycProvider);
    modifier onlyOwner() {
      require (msg.sender == owner);
      _;
    }
    modifier onlyDelegate() {
      require(delegate == msg.sender);
      _;
    }
    /// Set default security token parameters
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    function SecurityToken(string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner, address _polyTokenAddress) {
      owner = _owner;
      name = _name;
      symbol = _ticker;
      decimals = _decimals;
      totalSupply = _totalSupply;
      balances[_owner] = _totalSupply;
      POLY = PolyToken(_polyTokenAddress);
    }
    /// Propose a new compliance template for the Security Token
    /// @param _delegate Legal Delegate public ethereum address
    /// @param _complianceTemplate Compliance Template being proposed
    /// @return bool success
    function proposeComplianceTemplate(address _delegate, bytes32 _complianceTemplate) returns (bool success){
      //TODO require(complianceTemplateProposals[_delegate] == address(0));
      // complianceTemplateProposals[_delegate] = _complianceTemplate;
      LogComplianceTemplateProposal(_delegate, _complianceTemplate);
      return true;
    }
    /// Accept a Delegate's proposal
    /// @param _delegate Legal Delegates public ethereum address
    /// @return bool success
    function setDelegate(address _delegate) onlyOwner returns (bool success) {
      require(delegate == address(0));
      require(complianceTemplateProposals[_delegate].proposalValidUntil > now);
      require(complianceTemplateProposals[_delegate].templateValidUntil > now);
      require(POLY.balanceOf(this) >= complianceTemplateProposals[_delegate].delegateFee);
      delegate = _delegate;
      LogDelegateSet(_delegate);
      return true;
    }
    /// Update compliance proof
    /// @param _newMerkleRoot New merkle root hash of the compliance proofs
    /// @param _complianceProof Compliance proof hash
    /// @return bool success
    function updateComplianceProof(bytes32 _newMerkleRoot, bytes32 _complianceProof) returns (bool success) {
      require(msg.sender == owner || msg.sender == delegate);
      complianceProof = _newMerkleRoot;
      LogNewComplianceProof(_newMerkleRoot, _complianceProof);
      return true;
    }
    /// Set the STO contract address
    /// @param _securityTokenOfferingAddress Ethereum address of the STO contract
    /// @return bool success
    function setSTO(address _securityTokenOfferingAddress) onlyDelegate returns (bool success) {
      require(complianceProof != 0);
      //TODO require(_securityTokenOfferingAddress = address(0));
      STO = _securityTokenOfferingAddress;
      LogSecurityTokenOffering(_securityTokenOfferingAddress);
      return true;
    }
    /// Set the KYC provider
    /// @param _kycProvider Address of KYC provider
    /// @return bool success
    function setKYC(address _kycProvider) onlyOwner returns (bool success) {
      require(_kycProvider != address(0));
      require(complianceProof != 0);
      KYC = _kycProvider;
      LogSetKYC(_kycProvider);
      return true;
    }
    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && balances[msg.sender] >= _value && _value > 0) {
        return super.transfer(_to, _value); //super gives access to .transfer in parent contract
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
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && investors[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        return super.transferFrom(_from, _to, _value);
      } else {
        return false;
      }
    }
    /// Approve transfer of tokens manually
    /// @param _spender Address to approve transfer to
    /// @param _value Amount of tokens to approve for transfer
    /// @return bool success
    function approve(address _spender, uint256 _value) returns (bool success) {
      if (investors[_spender]) {
        return super.approve(_spender, _value);
      } else {
        return false;
      }
    }
    /// Allow transfer of any accidentally sent ERC20 tokens to the contract owner
    /// @param _tokenAddress Address of ERC20 token
    /// @param _amount Amount of tokens to send
    /// @return bool success
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
      return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}
contract SecurityTokens is Ownable {
    uint256 public totalSecurityTokens;
    address public polyTokenAddress;
    // Security Token
    struct SecurityTokenMetadata {
      string name;
      uint8 decimals;
      uint256 totalSupply;
      address owner;
      address tokenAddress;
      uint8 securityType;
    }
    // Mapping of ticker name to Security Token details
    mapping(string => SecurityTokenMetadata) securityTokens;
    // Security Token Offering Contract
    struct SecurityTokenOfferingContract {
      address creator;
      bool approved;
      uint256 fee;
    }
    // Mapping of contract creator address to contract details
    mapping(address => SecurityTokenOfferingContract) public securityTokenOfferingContracts;
    event LogNewSecurityToken(string indexed ticker, address securityTokenAddress, address owner);
    event LogNewSecurityTokenOffering(address contractAddress, bool approved);
    // Constructor
    function SecurityTokens(address _polyTokenAddress) {
      polyTokenAddress = _polyTokenAddress;
    }
    // Creates a new Security Token and saves it to the registry
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    /// @param _type Type of security being tokenized
    function createSecurityToken (string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner, uint8 _type) external {
      //TODO require(SecurityTokens[_ticker] != address(0));
      // Create the new Security Token contract
      address newSecurityTokenAddress = new SecurityToken(_name, _ticker, _decimals, _totalSupply, _owner, polyTokenAddress);
      // Update the registry
      SecurityTokenMetadata memory newToken = securityTokens[_ticker];
      newToken.name = _name;
      newToken.decimals = _decimals;
      newToken.totalSupply = _totalSupply;
      newToken.owner = _owner;
      newToken.securityType = _type;
      newToken.tokenAddress = newSecurityTokenAddress;
      securityTokens[_ticker] = newToken;
      // Log event and update total Security Token count
      LogNewSecurityToken(_ticker, newSecurityTokenAddress, owner);
      totalSecurityTokens++;
    }
    /// Allow new security token offering contract
    /// @param _contractAddress The security token offering contract's public key address
    /// @param _fee The fee charged for the services provided in POLY
    function newSecurityTokenOfferingContract(address _contractAddress, uint256 _fee) {
      require(_contractAddress != address(0));
      SecurityTokenOfferingContract memory newSTO = SecurityTokenOfferingContract({creator: msg.sender, approved: false, fee: _fee});
      securityTokenOfferingContracts[_contractAddress] = newSTO;
      LogNewSecurityTokenOffering(_contractAddress, false);
    }
    /// Approve or reject a security token offering contract application
    /// @param _contractAddress The legal delegate's public key address
    /// @param _approved Whether the security token offering contract was approved or not
    /// @param _fee the fee to perform the task
    function approveSecurityTokenOfferingContract(address _contractAddress, bool _approved, uint256 _fee) onlyOwner {
      require(_contractAddress != address(0));
      // require(securityTokenOfferingContracts[_contractAddress] != 0);
      if (_approved == true) {
        securityTokenOfferingContracts[_contractAddress].approved = true;
        securityTokenOfferingContracts[_contractAddress].fee = _fee;
        LogNewSecurityTokenOffering(_contractAddress, true);
      } else {
       delete securityTokenOfferingContracts[_contractAddress];
      }
    }
}
