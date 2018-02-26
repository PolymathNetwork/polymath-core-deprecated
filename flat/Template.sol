pragma solidity ^0.4.18;

interface ITemplate {

  /**
   * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
   * @param _allowedJurisdictions An array of jurisdictions
   * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
   */
  function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;

  /**
   * @dev `addDivisionJurisdiction` allows the adding of new jurisdictions to a template
   * @param _blockedDivisionJurisdictions An array of jurisdictions
   * @param _blocked An array of whether the jurisdiction is allowed to purchase the security or not
   */
  function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public;

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
   * @param _countryJurisdiction The ISO-3166 code of the investors country jurisdiction
   * @param _divisionJurisdiction The ISO-3166 code of the investors subdivision jurisdiction
   * @param _accredited Whether the investor is accredited or not
   * @param _role role of the user
   * @return allowed boolean variable
   */
  function checkTemplateRequirements(
      bytes32 _countryJurisdiction,
      bytes32 _divisionJurisdiction,
      bool _accredited,
      uint8 _role
  ) public view returns (bool allowed);

  /**
   * @dev getTemplateDetails is a constant function that gets template details
   * @return bytes32 details, bool finalized
   */
  function getTemplateDetails() view public returns (bytes32, bool);

  /**
   * @dev `getUsageDetails` is a function to get all the details on template usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);

  /**
   * @dev Get the list of allowed jurisdictions
   * @return bytes32[]
   */
  function getAllowedJurisdictionsList() view public returns (bytes32[]);

  /**
   * @dev Get the list of allowed roles
   * @return uin8[]
   */
  function getAllowedRolesList() view public returns (uint8[]);
    
  /**
   * @dev Get the list of allowed roles
   * @return bytes32[]
   */
  function getblockedDivisionJurisdictionsList() view public returns (bytes32[]);
}

/*
  Polymath compliance template is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  template allows security tokens to enforce purchase restrictions on chain and
  keep a log of documents for future auditing purposes.
*/



/**
 * @title Template
 * @dev  Template details used for the security token offering to ensure the regulatory compliance
 */

contract Template is ITemplate {

    string public VERSION = "1";

    address public owner;                                           // Address of the owner of template
    string public offeringType;                                     // Name of the security being issued
    bytes32 public issuerJurisdiction;                              // Variable contains the jurisdiction of the issuer of the template
    mapping(bytes32 => bool) public allowedJurisdictions;           // Mapping that contains the allowed staus of Jurisdictions
    mapping(bytes32 => bool) public blockedDivisionJurisdictions;   // Mapping that contains the allowed staus of Jurisdictions
    mapping(uint8 => bool) public allowedRoles;                     // Mapping that contains the allowed status of Roles
    bytes32[] public allowedJurisdictionsList;                      // List of allowed jurisdiction in the template
    bytes32[] public blockedDivisionJurisdictionsList;              // List of blocked divison jurisdiction in the template
    uint8[] public allowedRolesList;                                // List of allowed roles list
    bool public accredited;                                         // Variable that define the required level of accrediation for the investor
    address public KYC;                                             // Address of the KYC provider
    bytes32 details;                                                // Details of the offering requirements
    bool finalized;                                                 // Variable to know the status of the template (complete - true, not complete - false)
    uint256 public expires;                                         // Timestamp when template expires
    uint256 fee;                                                    // Amount of POLY to use the template (held in escrow until issuance)
    uint8 quorum;                                                   // Minimum percent of shareholders which need to vote to freeze
    uint256 vestingPeriod;                                          // Length of time to vest funds

    uint removedJurisdictionsCount;                                 // Keeps track of how many jurisdictions have been removed from allowed list for this template
    // Notification
    event DetailsUpdated(bytes32 _prevDetails, bytes32 _newDetails, uint _updateDate);
    event LogFinalizedTemplate(bool _finalized, uint256 _timestamp);

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
        require(_KYC != address(0) && _owner != address(0));
        require(_details.length > 0 && _expires > now && _issuerJurisdiction.length > 0);
        require(_quorum > 0 && _quorum <= 100);
        require(_vestingPeriod > 0);
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

    /**
     * @dev `addJurisdiction` allows the adding of new jurisdictions to a template
     * @param _allowedJurisdictions An array of jurisdictions
     * @param _allowed An array of whether the jurisdiction is allowed to purchase the security or not
     */
    function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(owner == msg.sender);
        require(_allowedJurisdictions.length == _allowed.length);
        require(!finalized);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            if (!allowedJurisdictions[_allowedJurisdictions[i]] && _allowed[i])
              allowedJurisdictionsList.push(_allowedJurisdictions[i]);
            else if (allowedJurisdictions[_allowedJurisdictions[i]] && !_allowed[i]) {
                removeFromJurisdictionList(_allowedJurisdictions[i]);
                removedJurisdictionsCount++;
            }
              
            allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /**
     * @dev `addDivisionJurisdiction` allows the adding of new jurisdictions to a template
     * @param _blockedDivisionJurisdictions An array of subdivision jurisdictions
     * @param _blocked An array of whether the subdivision jurisdiction is blocked to purchase the security or not
     */
    function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public {
        require(owner == msg.sender);
        require(_blockedDivisionJurisdictions.length == _blocked.length);
        require(!finalized);
        for (uint i = 0; i < _blockedDivisionJurisdictions.length; ++i) {
             if (!blockedDivisionJurisdictions[_blockedDivisionJurisdictions[i]] && _blocked[i])
                blockedDivisionJurisdictionsList.push(_blockedDivisionJurisdictions[i]);
            else if (blockedDivisionJurisdictions[_blockedDivisionJurisdictions[i]] && !_blocked[i]) {
                removeFromDivisionJurisdictionList(_blockedDivisionJurisdictions[i]);
            }
              
            blockedDivisionJurisdictions[_blockedDivisionJurisdictions[i]] = _blocked[i];
        }
    }

     /**
     * @dev remove the jurisdiction from the allowed list of jurisdictions
     * @param _jurisdiction Jurisdiction which need to be removed
     */
    function removeFromJurisdictionList(bytes32 _jurisdiction) internal {
        for (uint i = 0; i < allowedJurisdictionsList.length; i++) {
            if (allowedJurisdictionsList[i] == _jurisdiction)
                allowedJurisdictionsList[i] = 0x0;
        }
    }


    /**
     * @dev remove the divisionJurisdiction from the blocked list of divisionJurisdiction
     * @param _blockedDivisionJurisdiction divisionJurisdiction which need to be removed
     */
    function removeFromDivisionJurisdictionList(bytes32 _blockedDivisionJurisdiction) internal {
         for (uint i = 0; i < blockedDivisionJurisdictionsList.length; i++) {
            if (blockedDivisionJurisdictionsList[i] == _blockedDivisionJurisdiction)
                blockedDivisionJurisdictionsList[i] = 0x0;
        }
    }

    /**
     * @dev `addRoles` allows the adding of new roles to be added to whitelist
     * @param _allowedRoles User roles that can purchase the security
     */
    function addRoles(uint8[] _allowedRoles) public {
        require(owner == msg.sender);
        require(!finalized);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            if(!allowedRoles[_allowedRoles[i]])
                allowedRolesList.push(_allowedRoles[i]);

            allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /**
     * @notice `updateDetails`
     * @param _details details of the template need to change
     * @return allowed boolean variable
     */
    function updateDetails(bytes32 _details) public returns (bool allowed) {
        require(_details != 0x0);
        require(owner == msg.sender);
        bytes32 prevDetails = details;
        details = _details;
        DetailsUpdated(prevDetails, details, now);
        return true;
    }

    /**
     * @dev `finalizeTemplate` is used to finalize template.full compliance process/requirements
     * @return success
     */
    function finalizeTemplate() public returns (bool success) {
        require(owner == msg.sender);
        require(removedJurisdictionsCount != allowedJurisdictionsList.length);
        require(allowedRolesList.length > 0);
        finalized = true;
        LogFinalizedTemplate(finalized, now);
        return true;
    }

    /**
     * @dev `checkTemplateRequirements` is a constant function that checks if templates requirements are met
     * @param _countryJurisdiction The ISO-3166 code of the investors country jurisdiction
     * @param _divisionJurisdiction The ISO-3166 code of the investors subdivision jurisdiction
     * @param _accredited Whether the investor is accredited or not
     * @param _role role of the user
     * @return allowed boolean variable
     */
    function checkTemplateRequirements(
        bytes32 _countryJurisdiction,
        bytes32 _divisionJurisdiction,
        bool _accredited,
        uint8 _role
    ) public view returns (bool allowed)
    {
        require(_countryJurisdiction != 0x0);
        require(allowedJurisdictions[_countryJurisdiction] || !blockedDivisionJurisdictions[_divisionJurisdiction]);
        require(allowedRoles[_role]);
        if (accredited) {
            require(_accredited);
        }
        return true;
    }

    /**
     * @dev getTemplateDetails is a constant function that gets template details
     * @return bytes32 details, bool finalized
     */
    function getTemplateDetails() view public returns (bytes32, bool) {
        require(expires > now);
        return (details, finalized);
    }

    /**
     * @dev `getUsageDetails` is a function to get all the details on template usage fees
     * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, address KYC
     */
    function getUsageDetails() view public returns (uint256, uint8, uint256, address, address) {
        return (fee, quorum, vestingPeriod, owner, KYC);
    }

    /**
     * @dev Get the list of allowed jurisdictions
     * @return bytes32[]
     */
    function getAllowedJurisdictionsList() view public returns (bytes32[]) {
        return allowedJurisdictionsList;
    }

    /**
     * @dev Get the list of allowed roles
     * @return uin8[]
     */
    function getAllowedRolesList() view public returns (uint8[]) {
        return allowedRolesList;
    }

    /**
     * @dev Get the list of allowed roles
     * @return bytes32[]
     */
    function getblockedDivisionJurisdictionsList() view public returns (bytes32[]) {
        return blockedDivisionJurisdictionsList;
    }
}