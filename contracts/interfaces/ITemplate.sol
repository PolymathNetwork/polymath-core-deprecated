pragma solidity ^0.4.18;

interface ITemplate {

  /** 
   * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
   * @param _allowedJurisdictions An array of jurisdictions
   * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not 
   */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

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
   * @param _jurisdiction The ISO-3166 code of the investors jurisdiction
   * @param _accredited Whether the investor is accredited or not
   * @param _role role of the user
   * @return allowed boolean variable
   */
  function checkTemplateRequirements(
      bytes32 _jurisdiction,
      bool _accredited,
      uint8 _role
  ) public constant returns (bool allowed);

  /**
   * @dev check the authentication of the KYC addresses
   * @param _KYC address need to check
   */
  function validKYC(address _KYC) public returns (bool);
  
  /**
   * @dev getTemplateDetails is a constant function that gets template details
   * @return bytes32 details, bool finalized 
   */
  function getTemplateDetails() view public returns (bytes32, bool);

  /**
   * @dev `getUsageFees` is a function to get all the details on template usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address[10]);
}
