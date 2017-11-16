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
    string securityType;
    bytes32 issuerJurisdiction;
    mapping (bytes32 => bool) allowedJurisdictions;
    bool accredited;
    bytes32 complianceProcess;
    uint256 finalizes;
    uint256 expires;
    uint256 fee;
  }

  // All compliance templates are stored in a mapping
  mapping(bytes32 => Template) templates;

  // A legal delegate
  struct Delegate {
    bytes32 details;
    bytes32[] jurisdictions;
  }

  // All legal delegates are stored in a mapping
  mapping(address => Delegate) public delegates;

  // Notifications
  event NewDelegate(address _delegateAddress, bytes32[] _jurisdictions, bytes32 _details);
  event TemplateCreated(address creator, bytes32 _template, string _securityType);

  /// Allow new legal delegates to join Polymath
  /// @param _delegateAddress The legal delegate's public key address
  /// @param _details A SHA256 hash of the application document i.e. IPFS url
  /// @param _jurisdictions An array of jurisdictions they specialize in
  function newDelegate(address _delegateAddress, bytes32 _details, bytes32[] _jurisdictions) {
    require(_delegateAddress != address(0));
    require(delegates[_delegateAddress].details == 0);
    delegates[_delegateAddress].details = _details;
    delegates[_delegateAddress].jurisdictions = _jurisdictions;
    NewDelegate(_delegateAddress, _jurisdictions, _details);
  }

  /// Create a new compliance template
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _securityType The type of security being issued
  /// @param _issuerJurisdiction The jurisdiction id of the issuer
  /// @param _finalizes Timestamp of when the template will finalize and become non-editable
  /// @param _expires Timestamp of when the template will expire
  /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
  function createTemplate(
    bytes32 _template,
    string _securityType,
    bytes32 _issuerJurisdiction,
    bool _accredited,
    uint256 _finalizes,
    uint256 _expires,
    uint256 _fee
  ) {
    require(delegates[msg.sender].details != 0);
    require(templates[_template].owner == address(0));
    require(_finalizes > now);
    require(_expires >= _finalizes);
    templates[_template].owner = msg.sender;
    templates[_template].issuerJurisdiction = _issuerJurisdiction;
    templates[_template].securityType = _securityType;
    templates[_template].fee = _fee;
    templates[_template].accredited = _accredited;
    templates[_template].finalizes = _finalizes;
    templates[_template].expires = 0;
    TemplateCreated(msg.sender, _template, _securityType);
  }

  /// Allow adding of new jurisdictions to a template
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _allowedJurisdictions An array of jurisdictions
  /// @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
  function addJurisdictionToTemplate(bytes32 _template, bytes32[] _allowedJurisdictions, bool[] _allowed) {
    require(templates[_template].owner == msg.sender);
    require(templates[_template].finalizes > now);
    for(uint i = 0; i < _allowedJurisdictions.length; ++i) {
      templates[_template].allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
    }
  }

  /// Finalize template
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  function finalizeTemplate(bytes32 _template) {
    require(templates[_template].owner == msg.sender);
    require(templates[_template].finalizes > now);
    templates[_template].finalizes = now;
  }

  /// Check if template requirements are met
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _jurisdiction The ISO-3166 code of the investors jurisdiction
  /// @param _accredited Whether the investor is accredited or not
  function checkTemplateRequirements(bytes32 _template, bytes32 _jurisdiction, bool _accredited) returns (bool allowed) {
    require(_template != 0 && _jurisdiction != 0);
    require(templates[_template].allowedJurisdictions[_jurisdiction]);
    if (templates[_template].accredited) {
      require(_accredited);
    }
    return true;
  }

}
