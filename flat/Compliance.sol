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
     * @dev Set the STO contract by the issuer.
     * @param _factoryAddress address of the offering factory
     * @return bool success
     */
    function registerOfferingFactory (
        address _factoryAddress
    ) public returns (bool success);

    /**
     * @dev Cancel a STO contract proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringFactoryProposalIndex The offering proposal array index
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

interface IOfferingFactory {

  /**
   * @dev It facilitate the creation of the STO contract with essentials parameters
   * @param _startTime Unix timestamp to start the offering
   * @param _endTime Unix timestamp to end the offering
   * @param _polyTokenRate Price of one security token in terms of poly
   * @param _maxPoly Maximum amount of poly issuer wants to collect
   * @param _securityToken Address of the security token 
   * @return address Address of the new offering instance
   */
  function createOffering(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _polyTokenRate,
    uint256 _maxPoly,
    address _securityToken
    ) public returns (address);

  /**
   * @dev `getUsageDetails` is a function to get all the details on factory usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, string description
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, bytes32);

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
   * @param _providerAddress The provider's public key address
   * @param _name The provider's name
   * @param _details A SHA256 hash of the new providers details
   * @param _fee The fee charged for customer verification
   */
  function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);

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

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by providers.
*/




/**
 * @title Customers
 * @dev Contract use to register the user on the Platform platform
 */

contract Customers is ICustomers {

    string public VERSION = "1";

    IERC20 POLY;                                                        // Instance of the POLY token

    struct Customer {                                                   // Structure use to store the details of the customers
        bytes32 countryJurisdiction;                                    // Customers country jurisdiction as ex - ISO3166
        bytes32 divisionJurisdiction;                                   // Customers sub-division jurisdiction as ex - ISO3166
        uint256 joined;                                                 // Timestamp when customer register
        uint8 role;                                                     // role of the customer
        bool accredited;                                                // Accrediation status of the customer
        bytes32 proof;                                                  // Proof for customer
        uint256 expires;                                                // Timestamp when customer verification expires
    }

    mapping(address => mapping(address => Customer)) public customers;  // Customers (kyc provider address => customer address)
    mapping(address => mapping(uint256 => bool)) public nonceMap;       // Map of used nonces by customer

    struct Provider {                                                   // KYC/Accreditation Provider
        string name;                                                    // Name of the provider
        uint256 joined;                                                 // Timestamp when provider register
        bytes32 details;                                                // Details of provider
        uint256 fee;                                                    // Fee charged by the KYC providers
    }

    mapping(address => Provider) public providers;                      // KYC/Accreditation Providers

    // Notifications
    event LogNewProvider(address indexed providerAddress, string name, bytes32 details);
    event LogCustomerVerified(address indexed customer, address indexed provider, uint8 role);

    // Modifier
    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    /**
     * @dev Constructor
     */
    function Customers(address _polyTokenAddress) public {
        POLY = IERC20(_polyTokenAddress);
    }

    /**
     * @dev Allow new provider applications
     * @param _providerAddress The provider's public key address
     * @param _name The provider's name
     * @param _details A SHA256 hash of the new providers details
     * @param _fee The fee charged for customer verification
     */
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
        require(_providerAddress != address(0));
        require(_details != 0x0);
        require(providers[_providerAddress].details == 0x0);
        providers[_providerAddress] = Provider(_name, now, _details, _fee);
        LogNewProvider(_providerAddress, _name, _details);
        return true;
    }

    /**
     * @dev Change a providers fee
     * @param _newFee The new fee of the provider
     */
    function changeFee(uint256 _newFee) onlyProvider public returns (bool success) {
        providers[msg.sender].fee = _newFee;
        return true;
    }


    /**
     * @dev Verify an investor
     * @param _customer The customer's public key address
     * @param _countryJurisdiction The jurisdiction country code of the customer
     * @param _divisionJurisdiction The jurisdiction subdivision code of the customer
     * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
     * @param _accredited Whether the customer is accredited or not (only applied to investors)
     * @param _expires The time the verification expires
     * @param _nonce nonce of signature (avoid replay attack)
     * @param _v customer signature
     * @param _r customer signature
     * @param _s customer signature
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
    ) public onlyProvider returns (bool success)
    {
        require(_expires > now);
        require(nonceMap[_customer][_nonce] == false);
        nonceMap[_customer][_nonce] = true;
        bytes32 hash = keccak256(this, msg.sender, _countryJurisdiction, _divisionJurisdiction, _role, _accredited, _nonce);
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), _v, _r, _s) == _customer);
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].countryJurisdiction = _countryJurisdiction;
        customers[msg.sender][_customer].divisionJurisdiction = _divisionJurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        LogCustomerVerified(_customer, msg.sender, _role);
        return true;
    }

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
    ) {
      return (
        customers[_provider][_customer].countryJurisdiction,
        customers[_provider][_customer].divisionJurisdiction,
        customers[_provider][_customer].accredited,
        customers[_provider][_customer].role,
        customers[_provider][_customer].expires
      );
    }

    /**
     * Get provider details and fee by ethereum address
     * @param _providerAddress Address of the KYC provider
     */
    function getProvider(address _providerAddress) public view returns (
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
}

/*
  Polymath compliance template is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  template allows security tokens to enforce purchase restrictions on chain and
  keep a log of documents for future auditing purposes.
*/



/**
 * @title Template
 * @dev  Template details used for the security token offering to ensure the regulatory compliance
 */

contract Template is ITemplate {

    string public VERSION = "1";

    address public owner;                                           // Address of the owner of template
    string public offeringType;                                     // Name of the security being issued
    bytes32 public issuerJurisdiction;                              // Variable contains the jurisdiction of the issuer of the template
    mapping(bytes32 => bool) public allowedJurisdictions;           // Mapping that contains the allowed staus of Jurisdictions
    mapping(bytes32 => bool) public blockedDivisionJurisdictions;   // Mapping that contains the allowed staus of Jurisdictions
    mapping(uint8 => bool) public allowedRoles;                     // Mapping that contains the allowed status of Roles
    bool public accredited;                                         // Variable that define the required level of accrediation for the investor
    address public KYC;                                             // Address of the KYC provider
    bytes32 details;                                                // Details of the offering requirements
    bool finalized;                                                 // Variable to know the status of the template (complete - true, not complete - false)
    uint256 public expires;                                         // Timestamp when template expires
    uint256 fee;                                                    // Amount of POLY to use the template (held in escrow until issuance)
    uint8 quorum;                                                   // Minimum percent of shareholders which need to vote to freeze
    uint256 vestingPeriod;                                          // Length of time to vest funds

    event DetailsUpdated(bytes32 _prevDetails, bytes32 _newDetails, uint _updateDate);

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
        require(_KYC != address(0) && _owner != address(0));
        require(_details.length > 0 && _expires > now && _issuerJurisdiction.length > 0);
        require(_quorum > 0 && _quorum <= 100);
        require(_vestingPeriod > 0);
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

    /**
     * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
     * @param _allowedJurisdictions An array of jurisdictions
     * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
     */
    function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(owner == msg.sender);
        require(_allowedJurisdictions.length == _allowed.length);
        require(!finalized);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /**
     * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
     * @param _blockedDivisionJurisdictions An array of subdivision jurisdictions
     * @param _blocked An array of whether the subdivision jurisdiction is blocked to purchase the security or not
     */
    function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public {
        require(owner == msg.sender);
        require(_blockedDivisionJurisdictions.length == _blocked.length);
        require(!finalized);
        for (uint i = 0; i < _blockedDivisionJurisdictions.length; ++i) {
            blockedDivisionJurisdictions[_blockedDivisionJurisdictions[i]] = _blocked[i];
        }
    }

    /**
     * @dev `addRole` allows the adding of new roles to be added to whitelist
     * @param _allowedRoles User roles that can purchase the security
     */
    function addRoles(uint8[] _allowedRoles) public {
        require(owner == msg.sender);
        require(!finalized);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /**
     * @notice `updateDetails`
     * @param _details details of the template need to change
     * @return allowed boolean variable
     */
    function updateDetails(bytes32 _details) public returns (bool allowed) {
        require(_details != 0x0);
        require(owner == msg.sender);
        bytes32 prevDetails = details;
        details = _details;
        DetailsUpdated(prevDetails, details, now);
        return true;
    }

    /**
     * @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements
     * @return success
     */
    function finalizeTemplate() public returns (bool success) {
        require(owner == msg.sender);
        finalized = true;
        return true;
    }

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
    ) public view returns (bool allowed)
    {
        require(_countryJurisdiction != 0x0);
        require(allowedJurisdictions[_countryJurisdiction] || !blockedDivisionJurisdictions[_divisionJurisdiction]);
        require(allowedRoles[_role]);
        if (accredited) {
            require(_accredited);
        }
        return true;
    }

    /**
     * @dev getTemplateDetails is a constant function that gets template details
     * @return bytes32 details, bool finalized
     */
    function getTemplateDetails() view public returns (bytes32, bool) {
        require(expires > now);
        return (details, finalized);
    }

    /**
     * @dev `getUsageFees` is a function to get all the details on template usage fees
     * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
     */
    function getUsageDetails() view public returns (uint256, uint8, uint256, address, address) {
        return (fee, quorum, vestingPeriod, owner, KYC);
    }
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
     * @return bool
     */
    function initialiseOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, uint256 _maxPoly) external returns (bool success);

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

interface ISecurityTokenRegistrar {

   /**
    * @dev Creates a new Security Token and saves it to the registry
    * @param _nameSpace Name space for this security token
    * @param _name Name of the security token
    * @param _ticker Ticker name of the security
    * @param _totalSupply Total amount of tokens being created
    * @param _owner Ethereum public key address of the security token owner
    * @param _type Type of security being tokenized
    * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    * @param _quorum Percent of initial investors required to freeze POLY raise
    */
    function createSecurityToken (
        string _nameSpace,
        string _name,
        string _ticker,
        uint256 _totalSupply,
        uint8 _decimals,
        address _owner,
        uint8 _type,
        uint256 _lockupPeriod,
        uint8 _quorum
    ) external;

    /**
     * @dev Get Security token details by its ethereum address
     * @param _STAddress Security token address
     */
    function getSecurityTokenData(address _STAddress) public view returns (
      string,
      string,
      address,
      uint8
    );

}

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/








/**
 * @title Compilance
 * @dev Regulatory details offered by the security token
 */

contract Compliance is ICompliance {

    using SafeMath for uint256;

    string public VERSION = "1";

    ISecurityTokenRegistrar public STRegistrar;

    //Structure used to hold reputation for template and offeringFactories
    struct Reputation {
        uint256 totalRaised;                                             // Total amount raised by issuers that used the template / offeringFactory
        address[] usedBy;                                                // Array of security token addresses that used this particular template / offeringFactory
    }

    mapping(address => Reputation) public templates;                     // Mapping used for storing the template repuation
    mapping(address => address[]) public templateProposals;              // Template proposals for a specific security token

    mapping(address => Reputation) offeringFactories;                    // Mapping used for storing the offering factory reputation
    mapping(address => address[]) public offeringFactoryProposals;       // OfferingFactory proposals for a specific security token

    Customers public PolyCustomers;                                      // Instance of the Compliance contract
    uint256 public constant MINIMUM_VESTING_PERIOD = 60 * 60 * 24 * 100; // 100 Day minimum vesting period for POLY earned

    // Notifications for templates
    event LogTemplateCreated(address indexed _creator, address indexed _template, string _offeringType);
    event LogNewTemplateProposal(address indexed _securityToken, address indexed _template, address indexed _delegate, uint _templateProposalIndex);
    event LogCancelTemplateProposal(address indexed _securityToken, address indexed _template, uint _templateProposalIndex);

    // Notifications for offering factories
    event LogOfferingFactoryRegistered(address indexed _creator, address indexed _offeringFactory, bytes32 _description);
    event LogNewOfferingFactoryProposal(address indexed _securityToken, address indexed _offeringFactory, address indexed _owner, uint _offeringFactoryProposalIndex);
    event LogCancelOfferingFactoryProposal(address indexed _securityToken, address indexed _offeringFactory, uint _offeringFactoryProposalIndex);

    /* @param _polyCustomersAddress The address of the Polymath Customers contract */
    function Compliance(address _polyCustomersAddress) public {
        PolyCustomers = Customers(_polyCustomersAddress);
    }

    /**
     * @dev `setRegistrarAddress` This function set the SecurityTokenRegistrar contract address.
     * @param _STRegistrar It is the `this` reference of STR contract
     * @return bool
     */

    function setRegistrarAddress(address _STRegistrar) public returns (bool) {
        require(_STRegistrar != address(0));
        require(STRegistrar == address(0));
        STRegistrar = ISecurityTokenRegistrar(_STRegistrar);
        return true;
    }

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
    ) public
    {
      require(_KYC != address(0));
      require(_vestingPeriod >= MINIMUM_VESTING_PERIOD);
      require(_quorum > 0 && _quorum <= 100);

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
      templates[_template] = Reputation({
          totalRaised: 0,
          usedBy: new address[](0)
      });
      LogTemplateCreated(msg.sender, _template, _offeringType);
    }

    /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success)
    {
        // Verifying that provided _securityToken is generated by securityTokenRegistrar only
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(_securityToken);
        require(securityTokenOwner != address(0));

        // Creating the instance of template to avail the function calling
        ITemplate template = ITemplate(_template);

        //This will fail if template is expired
        var (,finalized) = template.getTemplateDetails();
        var (,,, owner,) = template.getUsageDetails();

        // Require that the caller is the template owner
        // and that the template has been finalized
        require(owner == msg.sender);
        require(finalized);

        //Get a reference of the template contract and add it to the templateProposals array
        templateProposals[_securityToken].push(_template);
        LogNewTemplateProposal(_securityToken, _template, msg.sender, templateProposals[_securityToken].length - 1);
        return true;
    }

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success)
    {
        address proposedTemplate = templateProposals[_securityToken][_templateProposalIndex];
        ITemplate template = ITemplate(proposedTemplate);
        var (,,, owner,) = template.getUsageDetails();

        require(owner == msg.sender);
        var (chosenTemplate,,,,,) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenTemplate != proposedTemplate);
        templateProposals[_securityToken][_templateProposalIndex] = address(0);
        LogCancelTemplateProposal(_securityToken, proposedTemplate, _templateProposalIndex);

        return true;
    }

    /**
     * @dev Set the STO contract by the issuer.
     * @param _factoryAddress address of the offering factory
     * @return bool success
     */
    function registerOfferingFactory(
      address _factoryAddress
    ) public returns (bool success)
    {
      require(_factoryAddress != address(0));
      IOfferingFactory offeringFactory = IOfferingFactory(_factoryAddress);
      var (, quorum, vestingPeriod, owner, description) = offeringFactory.getUsageDetails();

      //Validate Offering Factory details
      require(quorum > 0 && quorum <= 100);
      require(vestingPeriod >= MINIMUM_VESTING_PERIOD);
      require(owner != address(0));
      // Add the factory in the available list of factory addresses
      offeringFactories[_factoryAddress] = Reputation({
          totalRaised: 0,
          usedBy: new address[](0)
      });
      LogOfferingFactoryRegistered(owner, _factoryAddress, description);
      return true;
    }

    /**
     * @dev Propose a Security Token Offering Factory for an issuance
     * @param _securityToken The security token being bid on
     * @param _factoryAddress The address of the offering factory
     * @return bool success
     */
    function proposeOfferingFactory(
        address _securityToken,
        address _factoryAddress
    ) public returns (bool success)
    {
        // Verifying that provided _securityToken is generated by securityTokenRegistrar only
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(_securityToken);
        require(securityTokenOwner != address(0));

        IOfferingFactory offeringFactory = IOfferingFactory(_factoryAddress);
        var (,,, owner,) = offeringFactory.getUsageDetails();

        var (,,,,KYC,) = ISecurityToken(_securityToken).getTokenDetails();
        var (,,, expires) = PolyCustomers.getCustomer(KYC, owner);

        require(owner == msg.sender);
        require(expires > now);
        offeringFactoryProposals[_securityToken].push(_factoryAddress);
        LogNewOfferingFactoryProposal(_securityToken, _factoryAddress, owner, offeringFactoryProposals[_securityToken].length - 1);
        return true;
    }

    /**
     * @dev Cancel a STO factory proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringFactoryProposalIndex The offeringFactory proposal array index
     * @return bool success
     */
    function cancelOfferingFactoryProposal(
        address _securityToken,
        uint256 _offeringFactoryProposalIndex
    ) public returns (bool success)
    {
        address proposedOfferingFactory = offeringFactoryProposals[_securityToken][_offeringFactoryProposalIndex];
        IOfferingFactory offeringFactory = IOfferingFactory(proposedOfferingFactory);
        var (,,, owner,) = offeringFactory.getUsageDetails();

        require(owner == msg.sender);
        var (,,,,,chosenOfferingFactory) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenOfferingFactory != proposedOfferingFactory);
        offeringFactoryProposals[_securityToken][_offeringFactoryProposalIndex] = address(0);

        LogCancelOfferingFactoryProposal(_securityToken, proposedOfferingFactory, _offeringFactoryProposalIndex);
        return true;
    }

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template id
     * @param _polyRaised The amount of poly raised
     */
    function updateTemplateReputation(address _template, uint256 _polyRaised) external returns (bool success) {
        //Check that the caller is a security token
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(msg.sender);
        require(securityTokenOwner != address(0));
        //If it is, then update reputation
        templates[_template].usedBy.push(msg.sender);
        templates[_template].totalRaised = templates[_template].totalRaised.add(_polyRaised);
        return true;
    }

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offeringFactory contract to keep track of previous uses
     * @param _offeringFactory The address of the offering factory
     * @param _polyRaised The amount of poly raised
     */
    function updateOfferingFactoryReputation(address _offeringFactory, uint256 _polyRaised) external returns (bool success) {
        //Check that the caller is a security token
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(msg.sender);
        require(securityTokenOwner != address(0));
        //If it is, then update reputation
        offeringFactories[_offeringFactory].usedBy.push(msg.sender);
        offeringFactories[_offeringFactory].totalRaised = offeringFactories[_offeringFactory].totalRaised.add(_polyRaised);
        return true;
    }

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address _template
    ){
        return templateProposals[_securityTokenAddress][_templateIndex];
    }

    /**
     * @dev Get an array containing the address of all template proposals for a given ST
     * @param _securityTokenAddress The security token ethereum address
     * @return Template proposals array
     */
    function getAllTemplateProposals(address _securityTokenAddress) view public returns (address[]){
        return templateProposals[_securityTokenAddress];
    }

    /**
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringFactoryProposalIndex The array index of the STO contract being checked
     * @return Contract struct
     */
    function getOfferingFactoryByProposal(address _securityTokenAddress, uint8 _offeringFactoryProposalIndex) view public returns (
        address _offeringFactoryAddress
    ){
        return offeringFactoryProposals[_securityTokenAddress][_offeringFactoryProposalIndex];
    }

    /**
     * @dev Get an array containing the address of all offering proposals for a given ST
     * @param _securityTokenAddress The security token ethereum address
     * @return Offering proposals array
     */
    function getAllOfferingFactoryProposals(address _securityTokenAddress) view public returns (address[]) {
        return offeringFactoryProposals[_securityTokenAddress];
    }

}