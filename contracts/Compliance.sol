pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

import './Customers.sol';
import './Template.sol';
import './SecurityToken.sol';

contract Compliance {

    string public VERSION = "0.1";

    // A compliance template
    struct TemplateReputation {
      address owner;
      uint256 totalRaised;
      uint256 timesUsed;
      uint256 expires;
      address[] usedBy;
    }
    mapping(address => TemplateReputation) templates;

    // Template proposals for a specific security token
    mapping(address => address[]) public templateProposals;

    // Smart contract proposals for a specific security token
    struct Contract {
      address auditor;
      uint256 fee;
      uint256 vestingPeriod;
      uint32 quorum;
      address[] usedBy;
    }
    mapping(address => Contract) contracts;
    mapping(address => address[]) public contractProposals;

    // Instance of the Compliance contract
    Customers public PolyCustomers;

    // Notifications
    event TemplateCreated(address creator, address _template, string _name);
    event LogNewTemplateProposal(address _securityToken, address _template, address _delegate);
    event LogNewContractProposal(address _securityToken, address _contractAddress, address _delegate);
    
    /** 
     @param _polyCustomersAddress The address of the Polymath Customers contract
    */
    
    function Compliance(address _polyCustomersAddress) public {
      PolyCustomers = Customers(_polyCustomersAddress);
    }

    /**
        @dev `createTemplate` is a simple function to create a new compliance template
        @param _offeringType The name of the security being issued
        @param _issuerJurisdiction The jurisdiction id of the issuer
        @param _accredited Accreditation status required for investors
        @param _KYC KYC provider used by the template
        @param _details Details of the offering requirements
        @param _expires Timestamp of when the template will expire
        @param _fee Amount of POLY to use the template (held in escrow until issuance)
     */

    function createTemplate(
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
        var (,, role, verified, expires) = PolyCustomers.getCustomer(_KYC, msg.sender);
        require(role == 2 && verified && expires > now);
        require(_quorum > 0 && _quorum < 100);
        require(_vestingPeriod >= 7777777);
        address _template = new Template(
          msg.sender,
          _offeringType,
          _issuerJurisdiction,
          _accredited,
          _KYC,
          _details,
          _expires,
          _fee,
          _quorum,
          _vestingPeriod
        );
        templates[_template] = TemplateReputation({
          owner: msg.sender,
          totalRaised: 0,
          timesUsed: 0,
          expires: _expires,
          usedBy: new address[](0)
        });
        TemplateCreated(msg.sender, _template, _offeringType);
    }

    /**
        @dev Propose a bid for a security token issuance
        @param _securityToken The security token being bid on
        @param _template The unique template hash
        @return bool success
     */

    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success)
    {
        require(templates[_template].expires > now);
        require(templates[_template].owner == msg.sender);
        templateProposals[_securityToken].push(_template);
        LogNewTemplateProposal(_securityToken, _template, msg.sender);
        return true;
    }

    /**
        @dev Propose a STO contract for an issuance
        @param _securityToken The security token being bid on
        @param _contractAddress The security token offering contract address
        @return bool success
    */

    function proposeContract(
        address _securityToken,
        address _contractAddress
    ) public returns (bool success)
    {
        var (,,,KYC) = SecurityToken(_securityToken).getTokenDetails();
        var (,,, verified, expires) = PolyCustomers.getCustomer(KYC, contracts[_contractAddress].auditor);
        require(contracts[_contractAddress].auditor == msg.sender);
        require(verified == true);
        require(expires > now);
        contractProposals[_securityToken].push(_contractAddress);
        LogNewContractProposal(_securityToken, _contractAddress, msg.sender);
        return true;
    }

   /**
        @dev `updateTemplateReputation` is a constant function that updates the
        history of a security token to keep track of previous uses
        @param _template The unique template id
        @param _templateIndex The array index of the template proposal
    */

    function updateTemplateReputation (address _template, uint8 _templateIndex) public returns (bool success) {
      require(templateProposals[msg.sender][_templateIndex] == _template);
      templates[_template].usedBy.push(msg.sender);
      return true;
    }

  /**
        @dev `updateSmartContractReputation` is a constant function that updates the
         history of a security token to keep track of previous uses
        @param _contractAddress The smart contract address
        @param _contractIndex The array index of the contract proposal
   */

    function updateContractReputation (address _contractAddress, uint8 _contractIndex) public returns (bool success) {
      require(contractProposals[msg.sender][_contractIndex] == _contractAddress);
      contracts[_contractAddress].usedBy.push(msg.sender);
      return true;
    }

  /**
        @dev Get template details by the proposal index
        @param _securityTokenAddress The security token ethereum address
        @param _templateIndex The array index of the template being checked
        @return Template struct
   */

    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address template
    ){
      return templateProposals[_securityTokenAddress][_templateIndex];
    }

    /**
        @dev Get issuance smart contract details by the proposal index
        @param _securityTokenAddress The security token ethereum address
        @param _contractIndex The array index of the STO contract being checked
        @return Contract struct
     */
     
    function getContractByProposal(address _securityTokenAddress, uint8 _contractIndex) view public returns (
      address contractAddress,
      address auditor,
      uint256 vestingPeriod,
      uint32 quorum,
      uint256 fee
    ){
      address _contractAddress = contractProposals[_securityTokenAddress][_contractIndex];
      return (
        _contractAddress,
        contracts[_contractAddress].auditor,
        contracts[_contractAddress].vestingPeriod,
        contracts[_contractAddress].quorum,
        contracts[_contractAddress].fee
      );
    }

}
