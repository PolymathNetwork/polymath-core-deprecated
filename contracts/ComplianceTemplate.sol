pragma solidity ^0.4.15;

/*
Polymath compliance templates protocol is used to ensure regulatory compliance
in the jurisdictions that security tokens are being offered in. The compliance
protocol ensures security tokens remain interoperable so that anyone can
build on top of the Polymath platform and extend it's functionality.
*/

import './Ownable.sol';

contract ComplianceTemplate is Ownable {

  string public VERSION = '0.1';

  // A legal delegate may be approved for a specified period of time
  struct Delegate {
    bytes32 application;
    uint256 expires;
    uint8[] jurisdictions;
  }

  // An issuance template
  struct Template {
    address owner;
    uint8 tasks;
    uint8 issuerJurisdiction;
    uint8[] restrictedJurisdictions;
    bytes32 securityType;
    uint256 fee;
    uint256 expires;
    bool approved;
  }

  // All applicants are stored in a mapping
  mapping(address => bytes32) public applications;

  // All legal delegates are stored in a mapping
  mapping(address => Delegate) public delegates;

  // All compliance templates are stored in a mapping
  mapping(bytes32 => Template) public templates;

  // Notifications
  event DelegateApplication(address _delegateAddress, bytes32 _application);
  event DelegateApproved(address indexed _delegateAddress);
  event TemplateCreated(address creator, bytes32 _template, bytes32 _securityType);
  event TemplateApproved(bytes32 _template);

  /// Allow new legal delegate applications
  /// @param _delegateAddress The legal delegate's public key address
  /// @param _application A SHA256 hash of the application document
  function newDelegate(address _delegateAddress, bytes32 _application) {
    require(_delegateAddress != address(0));
    require(applications[_delegateAddress] == 0x0);
    applications[_delegateAddress] = _application;
    DelegateApplication(_delegateAddress, _application);
  }

  /// Approve or reject a new legal delegate application
  /// @param _delegateAddress The legal delegate's public key address
  /// @param _approved Is the delegate approved or not
  /// @param _jurisdictions The jurisdictions the delegate is qualified to create templates for
  /// @param _expires Timestamp the delegate is valid on Polymath until
  function approveDelegate(address _delegateAddress, bool _approved, uint8[] _jurisdictions, uint256 _expires) onlyOwner {
    require(_expires >= now);
    if (_approved == true) {
      require(_jurisdictions.length > 0);
      delegates[_delegateAddress].expires = _expires;
      delegates[_delegateAddress].jurisdictions = _jurisdictions;
      DelegateApproved(_delegateAddress);
    } else {
      delete delegates[_delegateAddress];
    }
  }

  /// Create a new compliance template
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _tasks The number of compliance tasks in the template
  /// @param _issuerJurisdiction The jurisdiction id of the issuer
  /// @param _restrictedJurisdictions An array of jurisdictions that are blocked from purchasing the security
  /// @param _securityType The type of security being issued
  /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
  /// @param _expires Timestamp of when the template will expire
  function createTemplate(
    bytes32 _template,
    uint8 _tasks,
    uint8 _issuerJurisdiction,
    uint8[] _restrictedJurisdictions,
    bytes32 _securityType,
    uint256 _fee,
    uint256 _expires
  ) {
    require(templates[_template].owner == 0x0);
    require(delegates[msg.sender].expires >= now);
    require(_tasks > 0);
    require(_expires > now);
    templates[_template].owner = msg.sender;
    templates[_template].tasks = _tasks;
    templates[_template].issuerJurisdiction = _issuerJurisdiction;
    templates[_template].restrictedJurisdictions = _restrictedJurisdictions;
    templates[_template].securityType = _securityType;
    templates[_template].fee = _fee;
    templates[_template].expires = 0;
    TemplateCreated(msg.sender, _template, _securityType);
  }

  /// Approve a new compliance template
  /// @param _template A SHA256 hash of the document containing full text of the compliance process/requirements
  /// @param _approved Whether the template is approved for use or not
  /// @param _expires Timestamp of when the template is valid to be applied to ST's until
  function approveTemplate(bytes32 _template, bool _approved, uint256 _expires) onlyOwner {
    require(templates[_template].expires == 0);
    if (_approved == true) {
      templates[_template].expires = _expires;
      TemplateApproved(_template);
    } else {
      delete templates[_template];
    }
  }

}
