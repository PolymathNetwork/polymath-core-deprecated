pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

interface ICompliance {

    /**
     * @dev `setRegistrarAddress` This function set the SecurityTokenRegistrar contract address.
     * @param _STRegistrar It is the `this` reference of STR contract
     * @return bool
     */

    function setRegistrarAddress(address _STRegistrar) public returns (bool);

    /**
     * @dev `createTemplate` is a simple function to create a new compliance template
     * @param _offeringType The name of the security being issued
     * @param _issuerJurisdiction The jurisdiction id of the issuer
     * @param _accredited Accreditation status required for investors
     * @param _KYC KYC provider used by the template
     * @param _details Details of the offering requirements
     * @param _expires Timestamp of when the template will expire
     * @param _fee Amount of POLY to use the template (held in escrow until issuance)
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     * @param _vestingPeriod Length of time to vest funds
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
    ) public;

   /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success);

    /**
     * @dev Propose a Security Token Offering Contract for an issuance
     * @param _securityToken The security token being bid on
     * @param _factoryAddress The security token offering contract address
     * @return bool success
     */
    function proposeOfferingFactory(
        address _securityToken,
        address _factoryAddress
    ) public returns (bool success);

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success);

    /**
     * @dev Set the STO contract by the issuer.
     * @param _factoryAddress address of the offering factory
     * @return bool success
     */
    function registerOfferingFactory (
        address _factoryAddress
    ) public returns (bool success);

    /**
     * @dev Cancel a STO contract proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringFactoryProposalIndex The offering proposal array index
     * @return bool success
     */
    function cancelOfferingFactoryProposal(
        address _securityToken,
        uint256 _offeringFactoryProposalIndex
    ) public returns (bool success);

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template address
     * @param _polyRaised Poly raised by template
     */
    function updateTemplateReputation (address _template, uint256 _polyRaised) external returns (bool success);

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offering contract to keep track of previous uses
     * @param _offeringFactory The smart contract address of the STO contract
     * @param _polyRaised Poly raised by template
     */
    function updateOfferingFactoryReputation (address _offeringFactory, uint256 _polyRaised) external returns (bool success);

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address _template
    );

    /**
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringFactoryProposalIndex The array index of the STO contract being checked
     * @return Contract struct
     */
    function getOfferingFactoryByProposal(address _securityTokenAddress, uint8 _offeringFactoryProposalIndex) view public returns (
        address _offeringFactoryAddress
    );
}
