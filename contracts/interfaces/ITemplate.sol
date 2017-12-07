pragma solidity ^0.4.15;

contract ITemplate {
  /// `createTemplate` is a simple function to create a new compliance template
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _attestor The attestation provider to be used for the issuance
  /// @param _name The name of security being issued
  /// @param _issuerJurisdiction The jurisdiction id of the issuer
  /// @param _finalizes Timestamp of when the template will finalize and become non-editable
  /// @param _expires Timestamp of when the template will expire
  /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
  function createTemplate(
      address _template,
      string _name,
      address _attestor,
      bytes32 _issuerJurisdiction,
      bool _accredited,
      uint256 _finalizes,
      uint256 _expires,
      uint256 _fee
  ) public;

  /// @notice `addJurisdictionToTemplate`allows the adding of new
  ///  jurisdictions to a template
  /// @param _template A SHA256 hash of the JSON schema containing full
  ///  compliance process/requirements
  /// @param _allowedJurisdictions An array of jurisdictions
  /// @param _allowed An array of whether the jurisdiction is allowed to
  ///  purchase the security or not
  function addJurisdictionToTemplate(bytes32 _template, bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /// @notice `addRoleToTemplate` allows the adding of new roles to be added to whitelist
  /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  /// @param _allowedRoles User roles that can purchase the security
  function addRolesToTemplate(bytes32 _template, uint8[] _allowedRoles) public;

  /// `finalizeTemplate` is used to finalize template.
  /// @param _template A SHA256 hash of the JSON schema containing
  ///  full compliance process/requirements
  function finalizeTemplate(bytes32 _template) public;

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
  ) public constant returns (bool allowed);
}
