pragma solidity ^0.4.18;

/*
  Polymath compliance template is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  template allows security tokens to enforce purchase restrictions on chain and
  keep a log of documents for future auditing purposes.
*/

import './interfaces/ITemplate.sol';

contract Template is ITemplate {

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
    uint8 quorum;
    uint256 vestingPeriod;

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

    /* @dev `addJurisdiction` allows the adding of new jurisdictions to a template
    @param _allowedJurisdictions An array of jurisdictions
    @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not */
    function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(owner == msg.sender);
        require(_allowedJurisdictions.length == _allowed.length);
        require(!finalized);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /* @dev `addRole` allows the adding of new roles to be added to whitelist
    @param _allowedRoles User roles that can purchase the security */
    function addRoles(uint8[] _allowedRoles) public {
        require(owner == msg.sender);
        require(!finalized);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /// @notice `updateDetails`
    function updateDetails(bytes32 _details) public returns (bool allowed) {
        require(_details != 0x0);
        require(owner == msg.sender);
        details = _details;
        return true;
    }

    /* @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements */
    function finalizeTemplate() public returns (bool success) {
        require(owner == msg.sender);
        finalized = true;
        return true;
    }

    /* @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
    @param _jurisdiction The ISO-3166 code of the investors jurisdiction
    @param _accredited Whether the investor is accredited or not */
    function checkTemplateRequirements(
        bytes32 _jurisdiction,
        bool _accredited,
        uint8 _role
    ) public constant returns (bool allowed)
    {
        require(_jurisdiction != 0x0);
        require(allowedJurisdictions[_jurisdiction] == true);
        require(allowedRoles[_role] == true);
        if (accredited == true) {
            require(_accredited == true);
        }
        return true;
    }

    /* getTemplateDetails is a constant function that gets template details
    @return bytes32 details, bool finalized */
    function getTemplateDetails() view public returns (bytes32, bool) {
        require(expires > now);
        return (details, finalized);
    }

    /// `getUsageFees` is a function to get all the details on template usage fees
    function getUsageDetails() view public returns (uint256, uint8, uint256, address, address) {
        return (fee, quorum, vestingPeriod, owner, KYC);
    }
}
