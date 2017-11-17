pragma solidity ^0.4.15;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

import './Customers.sol';

contract Compliance {

    string public VERSION = "0.1";

    // A compliance template
    struct Template {
        address owner;
        string name;
        bytes32 issuerJurisdiction;
        mapping (bytes32 => bool) allowedJurisdictions;
        bool[] allowedRoles;
        bool accredited;
        bytes32 complianceProcess;
        uint256 finalizes;
        uint256 expires;
        uint256 fee;
    }

    // All compliance templates are stored in a mapping
    mapping(bytes32 => Template) templates;

    // Instance of the Compliance contract
    Customers public PolyCustomers;

    // Notifications
    event TemplateCreated(address creator, bytes32 _template, string _name);

    /// `createTemplate` is a simple function to create a new compliance template
    /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
    /// @param _attestor The attestation provider to be used for the issuance
    /// @param _name The name of security being issued
    /// @param _issuerJurisdiction The jurisdiction id of the issuer
    /// @param _finalizes Timestamp of when the template will finalize and become non-editable
    /// @param _expires Timestamp of when the template will expire
    /// @param _fee Amount of POLY to use the template (held in escrow until issuance)
    function createTemplate(
        bytes32 _template,
        string _name,
        address _attestor,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        uint256 _finalizes,
        uint256 _expires,
        uint256 _fee
    ) public
    {
        var (jurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(_attestor, msg.sender);
        require(verified);
        require(role == 2);
        require(templates[_template].owner == address(0));
        require(_finalizes > now);
        require(_expires >= _finalizes);
        templates[_template].owner = msg.sender;
        templates[_template].issuerJurisdiction = _issuerJurisdiction;
        templates[_template].name = _name;
        templates[_template].name = _name;
        templates[_template].fee = _fee;
        templates[_template].accredited = _accredited;
        templates[_template].finalizes = _finalizes;
        templates[_template].expires = 0;
        TemplateCreated(msg.sender, _template, _name);
    }

    /// @notice `addJurisdictionToTemplate`allows the adding of new
    ///  jurisdictions to a template
    /// @param _template A SHA256 hash of the JSON schema containing full
    ///  compliance process/requirements
    /// @param _allowedJurisdictions An array of jurisdictions
    /// @param _allowed An array of whether the jurisdiction is allowed to
    ///  purchase the security or not
    function addJurisdictionToTemplate(bytes32 _template, bytes32[] _allowedJurisdictions, bool[] _allowed) public {
        require(templates[_template].owner == msg.sender);
        require(templates[_template].finalizes > now);
        for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
            templates[_template].allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
        }
    }

    /// @notice `addRoleToTemplate` allows the adding of new roles to be added to whitelist
    /// @param _template A SHA256 hash of the JSON schema containing full compliance process/requirements
    /// @param _allowedRoles User roles that can purchase the security
    function addRolesToTemplate(bytes32 _template, uint8[] _allowedRoles) public {
        require(templates[_template].owner == msg.sender);
        require(templates[_template].finalizes > now);
        for (uint i = 0; i < _allowedRoles.length; ++i) {
            templates[_template].allowedRoles[_allowedRoles[i]] = true;
        }
    }

    /// `finalizeTemplate` is used to finalize template.
    /// @param _template A SHA256 hash of the JSON schema containing
    ///  full compliance process/requirements
    function finalizeTemplate(bytes32 _template) public {
        require(templates[_template].owner == msg.sender);
        require(templates[_template].finalizes > now);
        templates[_template].finalizes = now;
    }

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
    ) public constant returns (bool allowed)
    {
        require(_template != 0 && _jurisdiction != 0);
        require(templates[_template].allowedJurisdictions[_jurisdiction] == true);
        require(templates[_template].allowedRoles[_role] == true);
        if (templates[_template].accredited == true) {
            require(_accredited == true);
        }
        return true;
    }

}
