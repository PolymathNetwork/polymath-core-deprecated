pragma solidity ^0.4.18;

interface ITemplate {

  /* @dev `addJurisdictionToTemplate`allows the adding of new
  jurisdictions to a template
  @param _template A SHA256 hash of the JSON schema containing full
  compliance process/requirements
  @param _allowedJurisdictions An array of jurisdictions
  @param _allowed An array of whether the jurisdiction is allowed to
  purchase the security or not */
  function addJurisdictionToTemplate(bytes32 _template, bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /* @dev `addRoleToTemplate` allows the adding of new roles to be added to whitelist
  @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
  @param _allowedRoles User roles that can purchase the security */
  function addRolesToTemplate(bytes32 _template, uint8[] _allowedRoles) public;

  /* @dev `finalizeTemplate` is used to finalize template.
  @param _template A SHA256 hash of the JSON schema containing
  full compliance process/requirements */
  function finalizeTemplate(bytes32 _template) public;

  /* @dev `checkTemplateRequirements` is a constant function that
  checks if templates requirements are met
  @param _jurisdiction The ISO-3166 code of the investors jurisdiction
  @param _accredited Whether the investor is accredited or not
  @param _role Check that the role is permitted */
  function checkTemplateRequirements(
    bytes32 _jurisdiction,
    bool _accredited,
    uint8 _role
  ) public constant returns (bool allowed);

  /// `getUsageDetails` is a function to get all the details on template usage fees
  function getUsageDetails() public constant returns (
    uint256 fee,
    uint8 quorum,
    uint256 vestingPeriod,
    address owner,
    address KYC
  );
}
