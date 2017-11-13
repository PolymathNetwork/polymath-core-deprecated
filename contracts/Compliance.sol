pragma solidity ^0.4.15;

/*
  Polymath compliance protocol is used to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol ensures security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

import './Ownable.sol';

contract Compliance is Ownable {

  string public VERSION = '0.1';

  // A compliance template
  struct Template {
    address owner;
    bytes32 complianceProcess;
    uint8 issuerJurisdiction;
    uint8[] allowedJurisdictions;
    bytes32 securityType;
    uint256 fee;
    uint256 expires;
  }

  // All compliance templates are stored in a mapping
  mapping(bytes32 => Template) public templates;

  // A compliance delegate
  struct Delegate {
    bytes32 information;
    bytes8[] jurisdictions;
  }

  // All legal delegates are stored in a mapping
  mapping(address => Delegate) public delegates;

  // Notifications
  event TemplateCreated(address creator, bytes32 _template, bytes32 _securityType);
  event NewDelegate(address _delegateAddress, bytes32 _information);

  /// Allow new legal delegate applications
  /// @param _delegateAddress The legal delegate's public key address
  /// @param _information A SHA256 hash of the application document/IPFS url
  /// @param _jurisdictions An array of jurisdictions
  function newDelegate(address _delegateAddress, bytes32 _information, bytes8[] _jurisdictions) {
    require(_delegateAddress != address(0));
    require(delegates[_delegateAddress].information == 0);
    delegates[_delegateAddress].information = _information;
    delegates[_delegateAddress].jurisdictions = _jurisdictions;
    NewDelegate(_delegateAddress, _information);
  }

  /// Create a new compliance template
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _issuerJurisdiction The jurisdiction id of the issuer
  /// @param _allowedJurisdictions An array of jurisdictions that are blocked from purchasing the security
  /// @param _securityType The type of security being issued
  /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
  /// @param _expires Timestamp of when the template will expire
  function createTemplate(
    bytes32 _template,
    uint8 _tasks,
    uint8 _issuerJurisdiction,
    uint8[] _allowedJurisdictions,
    bytes32 _securityType,
    uint256 _fee,
    uint256 _expires
  ) {
    require(templates[_template].owner == address(0));
    require(_expires > now);
    templates[_template].owner = msg.sender;
    templates[_template].issuerJurisdiction = _issuerJurisdiction;
    templates[_template].allowedJurisdictions = _allowedJurisdictions;
    templates[_template].securityType = _securityType;
    templates[_template].fee = _fee;
    templates[_template].expires = 0;
    TemplateCreated(msg.sender, _template, _securityType);
  }

}
