pragma solidity ^0.4.18;

interface ITemplate {

  /* @dev `addJurisdiction` allows the adding of new jurisdictions to a template
  @param _allowedJurisdictions An array of jurisdictions
  @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /* @dev `addRole` allows the adding of new roles to be added to whitelist
  @param _allowedRoles User roles that can purchase the security */
  function addRoles(uint8[] _allowedRoles) public;

  /// @notice `updateDetails`
  function updateDetails(bytes32 _details) public returns (bool allowed);

  /* @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements */
  function finalizeTemplate() public returns (bool success);

  /* @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
  @param _jurisdiction The ISO-3166 code of the investors jurisdiction
  @param _accredited Whether the investor is accredited or not */
  function checkTemplateRequirements(
      bytes32 _jurisdiction,
      bool _accredited,
      uint8 _role
  ) public constant returns (bool allowed);

  /* getTemplateDetails is a constant function that gets template details
  @return bytes32 details, bool finalized */
  function getTemplateDetails() view public returns (bytes32, bool);

  /// `getUsageFees` is a function to get all the details on template usage fees
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);
}
