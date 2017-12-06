pragma solidity ^0.4.15;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

import './Customers.sol';

contract Compliance {

    string public VERSION = "0.1";

    // A compliance template - Hard code royalty fee
    struct Template {
        address owner;
        string offeringType;
        bytes32 issuerJurisdiction;
        mapping (bytes32 => bool) allowedJurisdictions;
        bool[] allowedRoles;
        bool accredited;
        address KYC;
        bytes32 details;
        bool finalized;
        uint256 expires;
        uint256 fee;
        uint32 quorum;
        uint256 vestingPeriod;
        address[] usedBy;
    }
    mapping(bytes32 => Template) templates;

    // Template proposals for a specific security token
    mapping(address => bytes32[]) public templateProposals;

    // Smart contract proposals for a specific security token
    struct Contract {
      address auditor;
      uint256 fee;
      uint256 vestingPeriod;
      uint32 quorum;
      address[] usedBy;
    }
    mapping(address => Contract) contracts;
    mapping(address => address[]) public contractProposals;

    // Instance of the Compliance contract
    Customers public PolyCustomers;

    // Notifications
    event TemplateCreated(address creator, bytes32 _template, string _name);
    event LogNewDelgateProposal(address _securityToken, bytes32 _template, address _delegate);

    // Constructor
    /// @param _polyCustomersAddress The address of the Polymath Customers contract
    function Compliance(address _polyCustomersAddress) public {
      PolyCustomers = Customers(_polyCustomersAddress);
    }

    /// `createTemplate` is a simple function to create a new compliance template
    /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
    /// @param _offeringType The name of the security being issued
    /// @param _issuerJurisdiction The jurisdiction id of the issuer
    /// @param _accredited Accreditation status required for investors
    /// @param _KYC KYC provider used by the template
    /// @param _details Details of the offering requirements
    /// @param _finalized Timestamp of when the template will finalize and become non-editable
    /// @param _expires Timestamp of when the template will expire
    /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
    function createTemplate(
        bytes32 _template,
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        bool _finalized,
        uint256 _expires,
        uint256 _fee,
        uint32 _quorum,
        uint256 _vestingPeriod
    ) public
    {
        var (,, role, verified, expires) = PolyCustomers.getCustomer(_KYC, msg.sender);
        require(verified);
        require(role == 2);
        require(expires > now);
        require(templates[_template].owner == address(0));
        require(_quorum > 0 && _quorum < 100);
        require(_vestingPeriod >= 7777777);
        templates[_template].owner = msg.sender;
        templates[_template].offeringType = _offeringType;
        templates[_template].issuerJurisdiction = _issuerJurisdiction;
        templates[_template].accredited = _accredited;
        templates[_template].KYC = _KYC;
        templates[_template].details = _details;
        templates[_template].finalized = false;
        templates[_template].expires = _expires;
        templates[_template].fee = _fee;
        templates[_template].quorum = _quorum;
        templates[_template].vestingPeriod = _vestingPeriod;
        TemplateCreated(msg.sender, _template, _offeringType);
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

    /// @notice `updateDetails`
    function updateTemplateDetails(bytes32 _template, bytes32 _details) public constant returns (bool allowed) {
      require(_details != 0x0);
      require(templates[_template].owner = msg.sender);
      templates[_template].details = _details;
      return true;
    }

    /// `finalizeTemplate` is used to finalize template.
    /// @param _template A SHA256 hash of the JSON schema containing
    ///  full compliance process/requirements
    function finalizeTemplate(bytes32 _template) public {
        require(templates[_template].owner == msg.sender);
        templates[_template].finalized = true;
    }

    /// Propose a bid for a security token issuance
    /// @param _securityToken The security token being bid on
    /// @param _template The unique template hash
    /// @return bool success
    function proposeTemplate(
        address _securityToken,
        bytes32 _template
    ) public returns (bool success)
    {
        require(templates[_template].finalized == true);
        require(templates[_template].expires > now);
        require(templates[_template].owner == msg.sender);
        var (,, role, verified, expires) = PolyCustomers.getCustomer(templates[_template].KYC, msg.sender);
        require(verified == true);
        require(role == 2);
        templateProposals[_securityToken].push(_template);
        LogNewDelgateProposal(_securityToken, _template, msg.sender);
        return true;
    }

    /// Propose a STO contract for an issuance
    /// @param _securityToken The security token being bid on
    /// @param _contractAddress The security token offering contract address
    /// @param _template The unique template hash
    /// @param _templateIndex The array index of the template proposal
    /// @return bool success
    function proposeContract(
        address _securityToken,
        address _contractAddress,
        bytes32 _template,
        uint8 _templateIndex
    ) public returns (bool success)
    {
        var (,, role, verified, expires) = PolyCustomers.getCustomer(templates[_template].KYC, msg.sender);
        require(verified == true);
        require(role == 3);
        contractProposals[_securityToken].push(_contractAddress);
        LogNewDelgateProposal(_securityToken, _template, msg.sender);
        return true;
    }

    /// `updateTemplateReputation` is a constant function that updates the
    /// history of a security token to keep track of previous uses
    /// @param _template The unique template id
    /// @param _templateIndex The array index of the template proposal
    function updateTemplateReputation (bytes32 _template, uint8 _templateIndex) public returns (bool success) {
      require(templateProposals[msg.sender][_templateIndex] == _template);
      templates[_template].usedBy.push(msg.sender);
      templateProposals[msg.sender][_templateIndex].selected = true;
      return true;
    }

    /// `updateSmartContractReputation` is a constant function that updates the
    /// history of a security token to keep track of previous uses
    /// @param _contractAddress The smart contract address
    /// @param _contractIndex The array index of the contract proposal
    function updateContractReputation (address _contractAddress, uint8 _contractIndex) public returns (bool success) {
      require(contractProposals[msg.sender][_contractIndex] == _contractAddress);
      contractProposals[_contractAddress].usedBy.push(msg.sender);
      return true;
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

    /// `getTemplateDetails` is a constant function that gets template details
    /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
    /// @return bytes32 details
    function getTemplateDetails(bytes32 _template) public returns (bytes32 details, bool finalized) {
      require(templates[_template].expires > now);
      return (templates[_template].details, true);
    }

    /// Get template details by the proposal index
    /// @param _securityTokenAddress The security token ethereum address
    /// @param _templateIndex The array index of the template being checked
    /// return Template struct
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex)  public {
      return (templates[templateProposals[_securityTokenAddress][_templateIndex]]);
    }

    /// Get issuance smart contract details by the proposal index
    /// @param _securityTokenAddress The security token ethereum address
    /// @param _contractIndex The array index of the STO contract being checked
    /// return Contract struct
    function getContractByProposal(address _securityTokenAddress, uint8 _contractIndex) public {
      return (issuanceContracts[contractProposals[_securityTokenAddress][_contractIndex]]);
    }

}
