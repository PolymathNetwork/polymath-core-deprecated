pragma solidity ^0.4.18;

/**
 *  SafeMath <https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol/>
 *  Copyright (c) 2016 Smart Contract Solutions, Inc.
 *  Released under the MIT License (MIT)
 */

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
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function totalSupply() public view returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface ICustomers {

  /**
   * @dev Allow new provider applications
   * @param _name The provider's name
   * @param _details A SHA256 hash of the new providers details
   * @param _fee The fee charged for customer verification
   */
  function newProvider(string _name, bytes32 _details, uint256 _fee) public returns (bool success);

  /**
   * @dev Change a providers fee
   * @param _newFee The new fee of the provider
   */
  function changeFee(uint256 _newFee) public returns (bool success);

  /**
   * @dev Verify an investor
   * @param _customer The customer's public key address
   * @param _countryJurisdiction The country urisdiction code of the customer
   * @param _divisionJurisdiction The subdivision jurisdiction code of the customer
   * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
   * @param _accredited Whether the customer is accredited or not (only applied to investors)
   * @param _expires The time the verification expires
   */
  function verifyCustomer(
    address _customer,
    bytes32 _countryJurisdiction,
    bytes32 _divisionJurisdiction,
    uint8 _role,
    bool _accredited,
    uint256 _expires,
    uint _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public returns (bool success);

   ///////////////////
    /// GET Functions
    //////////////////

  /**
    * @dev Get customer attestation data by KYC provider and customer ethereum address
    * @param _provider Address of the KYC provider.
    * @param _customer Address of the customer ethereum address
    */
  function getCustomer(address _provider, address _customer) public view returns (
    bytes32,
    bytes32,
    bool,
    uint8,
    uint256
  );

  /**
   * Get provider details and fee by ethereum address
   * @param _providerAddress Address of the KYC provider
   */
  function getProvider(address _providerAddress) public view returns (
    string name,
    uint256 joined,
    bytes32 details,
    uint256 fee
  );
}

interface ISecurityToken {

   /**
     * @dev `selectTemplate` Select a proposed template for the issuance
     * @param _templateIndex Array index of the delegates proposed template
     * @return bool success
     */
    function selectTemplate(uint8 _templateIndex) public returns (bool success);

    /**
     * @dev Update compliance proof hash for the issuance
     * @param _newMerkleRoot New merkle root hash of the compliance Proofs
     * @param _complianceProof Compliance Proof hash
     * @return bool success
     */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public returns (bool success);

    /**
     * @dev `selectOfferingFactory` Select an security token offering proposal for the issuance
     * @param _offeringFactoryProposalIndex Array index of the STO proposal
     * @return bool success
     */
    function selectOfferingFactory (
        uint8 _offeringFactoryProposalIndex
    ) public returns (bool success);

    /**
     * @dev Start the offering by sending all the tokens to STO contract
     * @param _startTime Unix timestamp to start the offering
     * @param _endTime Unix timestamp to end the offering
     * @param _polyTokenRate Price of one security token in terms of poly
     * @param _maxPoly Maximum amount of poly issuer wants to collect
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     * @return bool
     */
    function initialiseOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, uint256 _maxPoly, uint256 _lockupPeriod, uint8 _quorum) external returns (bool success);

    /**
     * @dev Add a verified address to the Security Token whitelist
     * @param _whitelistAddress Address attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelist(address _whitelistAddress) public returns (bool success);

    /**
     * @dev Add verified addresses to the Security Token whitelist
     * @param _whitelistAddresses Array of addresses attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelistMulti(address[] _whitelistAddresses) public returns (bool success);

    /**
     * @dev Removes a previosly verified address to the Security Token blacklist
     * @param _blacklistAddress Address being added to the blacklist
     * @return bool success
     */
    function addToBlacklist(address _blacklistAddress) public returns (bool success);

    /**
     * @dev Removes previously verified addresseses to the Security Token whitelist
     * @param _blacklistAddresses Array of addresses attempting to join ST whitelist
     * @return bool success
     */
    function addToBlacklistMulti(address[] _blacklistAddresses) public returns (bool success);

     /**
      * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
      * @return bool success
      */
    function withdrawPoly() public returns (bool success);

    /**
     * @dev Vote to freeze the fee of a certain network participant
     * @param _recipient The fee recipient being protested
     * @return bool success
     */
    function voteToFreeze(address _recipient) public returns (bool success);

    /**
     * @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
     * @param _contributor The address of the person whose contributing
     * @param _amountOfSecurityTokens The amount of ST to pay out.
     * @param _polyContributed The amount of POLY paid for the security tokens.
     */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public returns (bool success);

    /// Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address, address);

    /// Get token decimals
    function decimals() view public returns (uint8);
  }

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

interface ICompliance {

    /**
     * @dev `setRegistrarAddress` This function set the SecurityTokenRegistrar contract address.
     * @param _STRegistrar It is the `this` reference of STR contract
     * @return bool
     */

    function setRegistrarAddress(address _STRegistrar) public returns (bool);

    /**
     * @dev `createTemplate` is a simple function to create a new compliance template
     * @param _offeringType The name of the security being issued
     * @param _issuerJurisdiction The jurisdiction id of the issuer
     * @param _accredited Accreditation status required for investors
     * @param _KYC KYC provider used by the template
     * @param _details Details of the offering requirements
     * @param _expires Timestamp of when the template will expire
     * @param _fee Amount of POLY to use the template (held in escrow until issuance)
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     * @param _vestingPeriod Length of time to vest funds
     */
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

   /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success);

    /**
     * @dev Propose a Security Token Offering Contract for an issuance
     * @param _securityToken The security token being bid on
     * @param _factoryAddress The security token offering contract address
     * @return bool success
     */
    function proposeOfferingFactory(
        address _securityToken,
        address _factoryAddress
    ) public returns (bool success);

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success);

   /**
     * @dev Register the Offering factory by the developer.
     * @param _factoryAddress address of the offering factory
     * @return bool success
     */
    function registerOfferingFactory (
        address _factoryAddress
    ) public returns (bool success);

    /**
     * @dev Cancel a Offering factory proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringFactoryProposalIndex The offeringFactory proposal array index
     * @return bool success
     */
    function cancelOfferingFactoryProposal(
        address _securityToken,
        uint256 _offeringFactoryProposalIndex
    ) public returns (bool success);

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template address
     * @param _polyRaised Poly raised by template
     */
    function updateTemplateReputation (address _template, uint256 _polyRaised) external returns (bool success);

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offering contract to keep track of previous uses
     * @param _offeringFactory The smart contract address of the STO contract
     * @param _polyRaised Poly raised by template
     */
    function updateOfferingFactoryReputation (address _offeringFactory, uint256 _polyRaised) external returns (bool success);

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address _template
    );

    /**
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringFactoryProposalIndex The array index of the STO contract being checked
     * @return Contract struct
     */
    function getOfferingFactoryByProposal(address _securityTokenAddress, uint8 _offeringFactoryProposalIndex) view public returns (
        address _offeringFactoryAddress
    );
}

interface ITemplate {

  /**
   * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
   * @param _allowedJurisdictions An array of jurisdictions
   * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
   */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /**
   * @dev `addDivisionJurisdiction` allows the adding of new jurisdictions to a template
   * @param _blockedDivisionJurisdictions An array of jurisdictions
   * @param _blocked An array of whether the jurisdiction is allowed to purchase the security or not
   */
  function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public;

  /**
   * @dev `addRole` allows the adding of new roles to be added to whitelist
   * @param _allowedRoles User roles that can purchase the security
   */
  function addRoles(uint8[] _allowedRoles) public;

  /**
   * @notice `updateDetails`
   * @param _details details of the template need to change
   * @return allowed boolean variable
   */
  function updateDetails(bytes32 _details) public returns (bool allowed);

  /**
   * @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements
   * @return success
   */
  function finalizeTemplate() public returns (bool success);

  /**
   * @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
   * @param _countryJurisdiction The ISO-3166 code of the investors country jurisdiction
   * @param _divisionJurisdiction The ISO-3166 code of the investors subdivision jurisdiction
   * @param _accredited Whether the investor is accredited or not
   * @param _role role of the user
   * @return allowed boolean variable
   */
  function checkTemplateRequirements(
      bytes32 _countryJurisdiction,
      bytes32 _divisionJurisdiction,
      bool _accredited,
      uint8 _role
  ) public view returns (bool allowed);

  /**
   * @dev getTemplateDetails is a constant function that gets template details
   * @return bytes32 details, bool finalized
   */
  function getTemplateDetails() view public returns (bytes32, bool);

  /**
   * @dev `getUsageDetails` is a function to get all the details on template usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);

  /**
   * @dev Get the list of allowed jurisdictions
   * @return bytes32[]
   */
  function getAllowedJurisdictionsList() view public returns (bytes32[]);

  /**
   * @dev Get the list of allowed roles
   * @return uin8[]
   */
  function getAllowedRolesList() view public returns (uint8[]);
    
  /**
   * @dev Get the list of allowed roles
   * @return bytes32[]
   */
  function getblockedDivisionJurisdictionsList() view public returns (bytes32[]);
}

interface IOfferingFactory {

  /**
   * @dev It facilitate the creation of the STO contract with essentials parameters
   * @param _startTime Unix timestamp to start the offering
   * @param _endTime Unix timestamp to end the offering
   * @param _polyTokenRate Price of one security token in terms of poly
   * @param _maxPoly Maximum amount of poly issuer wants to collect
   * @return address Address of the new offering instance
   */
  function createOffering(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _polyTokenRate,
    uint256 _maxPoly
    ) public returns (address);

  /**
   * @dev `getUsageDetails` is a function to get all the details on factory usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, string description
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, bytes32);

}

/**
 * @title SecurityToken
 * @dev Contract (A Blueprint) that contains the functionalities of the security token
 */

contract SecurityToken is ISecurityToken, IERC20 {

    using SafeMath for uint256;

    string public VERSION = "2";

    IERC20 public POLY;                                               // Instance of the POLY token contract

    ICompliance public PolyCompliance;                                // Instance of the Compliance contract

    ITemplate public Template;                                        // Instance of the Template contract

    IOfferingFactory public OfferingFactory;                          // Instance of the offering factory

    address public offering;                                          // Address of generated offering contract

    ICustomers public PolyCustomers;                                  // Instance of the Customers contract

    // ERC20 Fields
    string public name;                                               // Name of the security token
    string public symbol;                                             // Symbol of the security token
    uint8 public decimals;                                            // Decimals for the security token it should be 0 as standard
    address public owner;                                             // Address of the owner of the security token
    uint256 public totalSupply;                                       // Total number of security token generated
    mapping(address => mapping(address => uint256)) allowed;          // Mapping as same as in ERC20 token
    mapping(address => uint256) balances;                             // Array used to store the balances of the security token holders

    // Template
    address public delegate;                                          // Address who create the template
    address public KYC;                                               // Address of the KYC provider which aloowed the roles and jurisdictions in the template
    bytes32 public merkleRoot;

    // Security token shareholders
    struct Shareholder {                                              // Structure that contains the data of the shareholders
        address verifier;                                             // verifier - address of the KYC oracle
        bool allowed;                                                 // allowed - whether the shareholder is allowed to transfer or recieve the security token
        uint8 role;                                                   // role - role of the shareholder {1,2,3,4}
    }

    mapping(address => Shareholder) public shareholders;              // Mapping that holds the data of the shareholder corresponding to investor address

    // STO
    bool public isOfferingFactorySet = false;
    bool public isTemplateSet = false;
    uint256 public allocationStartTime = 0;

    // POLY allocations
    struct Allocation {                                               // Structure that contains the allocation of the POLY for stakeholders
        uint256 amount;                                               // stakeholders - delegate, issuer(owner), auditor
        uint256 vestingPeriod;
        uint256 yayVotes;
        uint256 yayPercent;
        uint8 quorum;
        bool frozen;
    }

    mapping(address => mapping(address => bool)) public voted;               // Voting mapping
    mapping(address => Allocation) public allocations;                       // Mapping that contains the data of allocation corresponding to stakeholder address

    // Security Token Offering statistics
    mapping(address => uint256) public contributedToSTO;                     // Mapping for tracking the POLY contribution by the contributor
    uint256 public totalAllocated = 0;

    // Notifications
    event LogTemplateSet(address indexed _delegateAddress, address indexed _template, address indexed _KYC);
    event LogUpdatedComplianceProof(bytes32 _merkleRoot, bytes32 _complianceProofHash);
    event LogOfferingFactorySet(address indexed _offeringFactory, address indexed _owner, bytes32 _description);
    event LogOfferingStarted(address indexed _offeringFactory, address indexed _owner, uint256 _startTime, uint256 _endTime, uint256 _fxPolyToken);
    event LogNewWhitelistedAddress(address indexed _KYC, address indexed _shareholder, uint8 _role);
    event LogNewBlacklistedAddress(address indexed _shareholder);
    event LogVoteToFreeze(address indexed _recipient, uint256 _yayPercent, uint8 _quorum, bool _frozen);
    event LogTokenIssued(address indexed _contributor, uint256 _stAmount, uint256 _polyContributed, uint256 _timestamp);

    //Modifiers
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

    modifier onlyOffering() {
        require (msg.sender == offering);
        _;
    }

    modifier onlyShareholder() {
        require (shareholders[msg.sender].allowed);
        _;
    }

    /**
     * @dev Set default security token parameters
     * @param _name Name of the security token
     * @param _ticker Ticker name of the security
     * @param _totalSupply Total amount of tokens being created
     * @param _owner Ethereum address of the security token owner
     * @param _polyTokenAddress Ethereum address of the POLY token contract
     * @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
     * @param _polyComplianceAddress Ethereum address of the PolyCompliance contract
     */
    function SecurityToken(
        string _name,
        string _ticker,
        uint256 _totalSupply,
        uint8 _decimals,
        address _owner,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public
    {
        decimals = _decimals;
        name = _name;
        symbol = _ticker;
        owner = _owner;
        totalSupply = _totalSupply;
        balances[_owner] = _totalSupply;
        POLY = IERC20(_polyTokenAddress);
        PolyCustomers = ICustomers(_polyCustomersAddress);
        PolyCompliance = ICompliance(_polyComplianceAddress);
        Transfer(0x0, _owner, _totalSupply);
    }

    /**
     * @dev `selectTemplate` Select a proposed template for the issuance
     * @param _templateIndex Array index of the delegates proposed template
     * @return bool success
     */
    function selectTemplate(uint8 _templateIndex) public onlyOwner returns (bool success) {
        require(!isTemplateSet);
        isTemplateSet = true;
        address template = ITemplate(PolyCompliance.getTemplateByProposal(this, _templateIndex));
        require(template != address(0));
        Template = ITemplate(template);
        var (_fee, _quorum, _vestingPeriod, _delegate, _KYC) = Template.getUsageDetails();
        require(POLY.balanceOf(this) >= _fee);
        allocations[_delegate] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
        totalAllocated = totalAllocated.add(_fee);
        delegate = _delegate;
        KYC = _KYC;
        PolyCompliance.updateTemplateReputation(template, 0);
        LogTemplateSet(_delegate, template, _KYC);
        return true;
    }

    /**
     * @dev Update compliance proof hash for the issuance
     * @param _newMerkleRoot New merkle root hash of the compliance Proofs
     * @param _merkleRoot Compliance Proof hash
     * @return bool success
     */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _merkleRoot
    ) public onlyOwnerOrDelegate returns (bool success)
    {
        merkleRoot = _newMerkleRoot;
        LogUpdatedComplianceProof(merkleRoot, _merkleRoot);
        return true;
    }

    /**
     * @dev `selectOfferingProposal` Select an security token offering proposal for the issuance
     * @param _offeringFactoryProposalIndex Array index of the STO proposal
     * @return bool success
     */
    function selectOfferingFactory(uint8 _offeringFactoryProposalIndex) public onlyDelegate returns (bool success) {
        require(!isOfferingFactorySet);
        require(merkleRoot != 0x0);
        isOfferingFactorySet = true;
        address offeringFactory = PolyCompliance.getOfferingFactoryByProposal(this, _offeringFactoryProposalIndex);
        require(offeringFactory != address(0));

        OfferingFactory = IOfferingFactory(offeringFactory);
        var (_fee, _quorum, _vestingPeriod, _owner, _description) = OfferingFactory.getUsageDetails();
        require(POLY.balanceOf(this) >= totalAllocated.add(_fee));
        allocations[_owner] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
        totalAllocated = totalAllocated.add(_fee);

        PolyCompliance.updateOfferingFactoryReputation(offeringFactory, 0);
        LogOfferingFactorySet(offeringFactory, _owner, _description);
        return true;
    }

    /**
     * @dev Start the offering by sending all the tokens to STO contract
     * @param _startTime Unix timestamp to start the offering
     * @param _endTime Unix timestamp to end the offering
     * @param _polyTokenRate Price of one security token in terms of poly
     * @param _maxPoly Maximum amount of poly issuer wants to collect
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     * @return bool
     */
    function initialiseOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, uint256 _maxPoly, uint256 _lockupPeriod, uint8 _quorum) onlyOwner external returns (bool success) {
        require(isOfferingFactorySet);
        require(offering == address(0));
        allocationStartTime = _startTime;
        require(_startTime > now && _endTime > _startTime);
        require(_lockupPeriod >= now);
        allocations[owner] = Allocation(0, _lockupPeriod, _quorum, 0, 0, false);
        // Creation of the new instance of the offering contract to facilitate the offering of this security token
        offering = OfferingFactory.createOffering(_startTime, _endTime, _polyTokenRate, _maxPoly);
        shareholders[offering] = Shareholder(this, true, 5);
        uint256 tokenAmount = this.balanceOf(msg.sender);
        require(tokenAmount == totalSupply);
        balances[offering] = balances[offering].add(tokenAmount);
        balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
        Transfer(owner, offering, tokenAmount);
        return true;
    }

    /**
     * @dev Add a verified address to the Security Token whitelist
     * The Issuer can add an address to the whitelist by themselves by
     * creating their own KYC provider and using it to verify the accounts
     * they want to add to the whitelist.
     * @param _whitelistAddress Address attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelist(address _whitelistAddress) onlyOwner public returns (bool success) {
        var (countryJurisdiction, divisionJurisdiction, accredited, role, expires) = PolyCustomers.getCustomer(KYC, _whitelistAddress);
        require(expires > now);
        require(Template.checkTemplateRequirements(countryJurisdiction, divisionJurisdiction, accredited, role));
        shareholders[_whitelistAddress] = Shareholder(KYC, true, role);
        LogNewWhitelistedAddress(KYC, _whitelistAddress, role);
        return true;
    }

    /**
     * @dev Add verified addresses to the Security Token whitelist
     * @param _whitelistAddresses Array of addresses attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelistMulti(address[] _whitelistAddresses) onlyOwner public returns (bool success) {
      for (uint256 i = 0; i < _whitelistAddresses.length; i++) {
        addToWhitelist(_whitelistAddresses[i]);
      }
      return true;
    }

    /**
     * @dev Add a verified address to the Security Token blacklist
     * @param _blacklistAddress Address being added to the blacklist
     * @return bool success
     */
    function addToBlacklist(address _blacklistAddress) onlyOwner public returns (bool success) {
        require(shareholders[_blacklistAddress].allowed);
        shareholders[_blacklistAddress].allowed = false;
        LogNewBlacklistedAddress(_blacklistAddress);
        return true;
    }

    /**
     * @dev Removes previously verified addresseses to the Security Token whitelist
     * @param _blacklistAddresses Array of addresses attempting to join ST whitelist
     * @return bool success
     */
    function addToBlacklistMulti(address[] _blacklistAddresses) onlyOwner public returns (bool success) {
      for (uint256 i = 0; i < _blacklistAddresses.length; i++) {
        addToBlacklist(_blacklistAddresses[i]);
      }
      return true;
    }

    /**
     * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
     * @return bool success
     */
    function withdrawUnallocatedPoly() public onlyOwner returns (bool success) {
      require(POLY.balanceOf(this) > totalAllocated);
      require(POLY.transfer(owner, POLY.balanceOf(this).sub(totalAllocated)));
      return true;
    }

    /**
     * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
     * @return bool success
     */
    function withdrawPoly() public returns (bool success) {
      require(offering != address(0));
      require(now > allocationStartTime.add(allocations[msg.sender].vestingPeriod));
      require(!allocations[msg.sender].frozen);
      require(allocations[msg.sender].amount > 0);
      require(POLY.transfer(msg.sender, allocations[msg.sender].amount));
      allocations[msg.sender].amount = 0;
      return true;
    }

    /**
     * @dev Vote to freeze the fee of a certain network participant
     * @param _recipient The fee recipient being protested
     * @return bool success
     */
    function voteToFreeze(address _recipient) public onlyShareholder returns (bool success) {
      require(delegate != address(0));
      require(offering != address(0));
      require(now > allocationStartTime);
      require(now < allocationStartTime.add(allocations[_recipient].vestingPeriod));
      require(!voted[msg.sender][_recipient]);
      voted[msg.sender][_recipient] = true;
      allocations[_recipient].yayVotes = allocations[_recipient].yayVotes.add(contributedToSTO[msg.sender]);
      allocations[_recipient].yayPercent = allocations[_recipient].yayVotes.mul(100).div(allocations[owner].amount);
      if (allocations[_recipient].yayPercent >= allocations[_recipient].quorum) {
        allocations[_recipient].frozen = true;
      }
      LogVoteToFreeze(_recipient, allocations[_recipient].yayPercent, allocations[_recipient].quorum, allocations[_recipient].frozen);
      return true;
    }

	/**
     * @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
     * @param _contributor The address of the person whose contributing
     * @param _amountOfSecurityTokens The amount of ST to pay out.
     * @param _polyContributed The amount of POLY paid for the security tokens.
     */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public onlyOffering returns (bool success) {
      // Check whether the offering active or not
      require(offering != address(0));
      // The _contributor being issued tokens must be in the whitelist
      require(shareholders[_contributor].allowed);
      // In order to issue the ST, the _contributor first pays in POLY
      require(POLY.transferFrom(_contributor, this, _polyContributed));
      // Update ST balances (transfers ST from STO to _contributor)
      balances[offering] = balances[offering].sub(_amountOfSecurityTokens);
      balances[_contributor] = balances[_contributor].add(_amountOfSecurityTokens);
      // Update Reputations
      PolyCompliance.updateOfferingFactoryReputation(address(OfferingFactory), _polyContributed);
      PolyCompliance.updateTemplateReputation(address(Template), _polyContributed);
      // ERC20 Transfer event
      Transfer(offering, _contributor, _amountOfSecurityTokens);
      // Update the amount of POLY a contributor has contributed and allocated to the owner
      contributedToSTO[_contributor] = contributedToSTO[_contributor].add(_polyContributed);
      allocations[owner].amount = allocations[owner].amount.add(_polyContributed);
      totalAllocated = totalAllocated.add(_polyContributed);
      LogTokenIssued(_contributor, _amountOfSecurityTokens, _polyContributed, now);
      return true;
    }

    // Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address, address) {
        return (Template, delegate, merkleRoot, OfferingFactory, KYC, offering);
    }

/////////////////////////////////////////////// Customized ERC20 Functions ////////////////////////////////////////////////////////////

    /**
     * @dev Trasfer tokens from one address to another
     * @param _to Ethereum public address to transfer tokens to
     * @param _value Amount of tokens to send
     * @return bool success
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to].allowed && shareholders[msg.sender].allowed && balances[msg.sender] >= _value) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Allows contracts to transfer tokens on behalf of token holders
     * @param _from Address to transfer tokens from
     * @param _to Address to send tokens to
     * @param _value Number of tokens to transfer
     * @return bool success
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to].allowed && shareholders[_from].allowed && balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            uint256 _allowance = allowed[_from][msg.sender];
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = _allowance.sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev `balanceOf` used to get the balance of shareholders
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Approve transfer of tokens manually
     * @param _spender Address to approve transfer to
     * @param _value Amount of tokens to approve for transfer
     * @return bool success
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Use to get the allowance provided to the spender
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function totalSupply() public view returns (uint256) {
      return totalSupply;
    }

    function decimals() public view returns (uint8) {
      return decimals;
    }
}