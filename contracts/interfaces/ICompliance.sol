pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

interface ICompliance {

    /* @dev `createTemplate` is a simple function to create a new compliance template
    @param _offeringType The name of the security being issued
    @param _issuerJurisdiction The jurisdiction id of the issuer
    @param _accredited Accreditation status required for investors
    @param _KYC KYC provider used by the template
    @param _details Details of the offering requirements
    @param _expires Timestamp of when the template will expire
    @param _fee Amount of POLY to use the template (held in escrow until issuance)
    @param _quorum Minimum percent of shareholders which need to vote to freeze
    @param _vestingPeriod Length of time to vest funds */
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

    /* @dev Propose a bid for a security token issuance
    @param _securityToken The security token being bid on
    @param _template The unique template address
    @return bool success */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success);

    /* @dev Propose a Security Token Offering Contract for an issuance
    @param _securityToken The security token being bid on
    @param _stoContract The security token offering contract address
    @return bool success */
    function proposeOfferingContract(
        address _securityToken,
        address _stoContract
    ) public returns (bool success);

    /* @dev Cancel a Template proposal if the bid hasn't been accepted
    @param _securityToken The security token being bid on
    @param _templateProposalIndex The template proposal array index
    @return bool success */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success);

    /* @dev Set the STO contract by the issuer.
       @param _STOAddress address of the STO contract deployed over the network.
       @param _fee fee to be paid in poly to use that contract
       @param _vestingPeriod no. of days investor binded to hold the Security token
       @param _quorum Minimum percent of shareholders which need to vote to freeze*/
    function setSTO (
        address _STOAddress,
        uint256 _fee,
        uint256 _vestingPeriod,
        uint8 _quorum
    ) public returns (bool success);

    /* @dev Cancel a STO contract proposal if the bid hasn't been accepted
    @param _securityToken The security token being bid on
    @param _offeringProposalIndex The offering proposal array index
    @return bool success */
    function cancelOfferingProposal(
        address _securityToken,
        uint256 _offeringProposalIndex
    ) public returns (bool success);

    /* @dev `updateTemplateReputation` is a constant function that updates the
     history of a security token template usage to keep track of previous uses
    @param _template The unique template id
    @param _templateIndex The array index of the template proposal */
    function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success);

    /* @dev `updateOfferingReputation` is a constant function that updates the
     history of a security token offering contract to keep track of previous uses
    @param _contractAddress The smart contract address of the STO contract
    @param _offeringProposalIndex The array index of the security token offering proposal */
    function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success);

    /* @dev Get template details by the proposal index
    @param _securityTokenAddress The security token ethereum address
    @param _templateIndex The array index of the template being checked
    @return Template struct */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address template
    );

    /* @dev Get security token offering smart contract details by the proposal index
    @param _securityTokenAddress The security token ethereum address
    @param _offeringProposalIndex The array index of the STO contract being checked
    @return Contract struct */
    function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
        address stoContract,
        address auditor,
        uint256 vestingPeriod,
        uint8 quorum,
        uint256 fee
    );
}
