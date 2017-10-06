pragma solidity ^0.4.15;

/*
Polymath compliance templates protocol is used to ensure regulatory compliance
in the jurisdictions that security tokens are being offered in. The compliance
protocol ensures security tokens remain interoperable so that anyone can
build on top of the Polymath platform and extend it's functionality.
*/

import './Ownable.sol';

contract IssuanceTemplate is Ownable {

  // A legal delegate may be approved for a specified period of time
  struct Delegate {
    bytes32 application;
    uint256 expires;
    uint8[] jurisdictions;
  }

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

  // All legal delegates are stored in a mapping
  mapping(address => Delegate) public delegates;

  // All compliance templates are stored in a mapping
  mapping(uint256 => Template) public templates;

  // Notifications
  event LogDelegateApplication(address _delegateAddress, bytes32 _application);
  event LogDelegateApproved(address indexed _delegateAddress);
  event LogNewTemplate(address creator, string _template, string desc);

  /// Allow new legal delegate applications
  /// @param _delegateAddress The legal delegate's public key address
  /// @param _application A SHA256 hash of the application document
  function newDelegate(address _delegateAddress, bytes32 _application) {
    require(_delegateAddress != address(0));
    delegates[_delegateAddress] = Delegate(_application, now, []);
    LogDelegateApplication(_delegateAddress, _application);
  }

  /// Approve or reject a new legal delegate application
  /// @param _delegateAddress The legal delegate's public key address
  /// @param _jurisdictions The jurisdictions the delegate is qualified to create templates for
  function approveDelegate(address _delegateAddress, bool approved, uint8[] _jurisdictions, uint256 _expires) onlyOwner {
    require(delegates[_delegateAddress].jurisdictions.length == 0);
    require(_expires >= now);
    if (approved == true) {
      require(_jurisdictions.length > 0);
      delegates[_delegateAddress].approved = true;
      delegates[_delegateAddress].expires = _expires;
      delegates[_delegateAddress].jurisdictions = _jurisdictions;
    } else {
      delete delegates[_delegateAddress];
    }
  }

  /// Create a new compliance template
  /// @param _delegateAddress The public key of the legal delegate who owns the template
  /// @param _template A SHA256 hash of the document containing full text of the compliance process/requirements
  /// @param _tasks The number of compliance tasks in the template
  /// @param _issuerJurisdiction The jurisdiction id of the issuer
  /// @param _restrictedJurisdictions An array of jurisdictions that are blocked from purchasing the security
  /// @param _securityType The type of security being issued
  /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
  /// @param _expires Timestamp of when the template will expire
  function newTemplate(
    string _template,
    uint8 _tasks,
    uint8 _issuerJurisdiction,
    uint8[] _restrictedJurisdictions,
    bytes32 _securityType,
    uint256 _fee,
    uint256 _expires
  ) {
    require(delegates[_delegateAddress].approved);
    require(delegates[_delegateAddress].expires >= now);
    require(_tasks > 0);
    require(_expires > now);
    templates[_template].owner = msg.sender;
    templates[_template].tasks = _tasks;
    templates[_template].issuerJurisdiction = _issuerJurisdiction;
    templates[_template].restrictedJurisdictions = _restrictedJurisdictions;
    templates[_template].securityType = _securityType;
    templates[_template].fee = _fee;
    templates[_template].expires = 0;
    LogNewTemplate(msg.sender, _template, _desc);
  }

  /// Approve a new compliance template
  /// @param _template A SHA256 hash of the document containing full text of the compliance process/requirements
  /// @param _approved Whether the template is approved for use or not
  /// @param _expires Timestamp of when the template is valid to be applied to ST's until
  function approveTemplate(string _template, bool _approved, uint256 _expires) onlyOwner {
    require(templates[_template]._expires == 0);
    if (approved == true) {
      templates[_template]._expires = _expires;
    } else {
      delete templates[_template];
    }
  }

}
