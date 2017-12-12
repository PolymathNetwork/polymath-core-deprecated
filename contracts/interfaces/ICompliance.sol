pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

contract ICompliance {

    /**
        @dev Get template details by the proposal index
        @param _securityTokenAddress The security token ethereum address
        @param _templateIndex The array index of the template being checked
        @return Template struct
     */

    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) public returns (
        address template
    );

    /**
        @dev Get issuance smart contract details by the proposal index
        @param _securityTokenAddress The security token ethereum address
        @param _contractIndex The array index of the STO contract being checked
        @return Contract struct
    */

    function getContractByProposal(address _securityTokenAddress, uint8 _contractIndex) public returns (
      address contractAddress,
      address auditor,
      uint256 vestingPeriod,
      uint8 quorum,
      uint256 fee
    );

   /**
        @dev `updateTemplateReputation` is a constant function that updates the
        history of a security token to keep track of previous uses
        @param _template The unique template id
        @param _templateIndex The array index of the template proposal
  */

    function updateTemplateReputation (address _template, uint8 _templateIndex) public returns (bool success);

    /**
        @dev `updateSmartContractReputation` is a constant function that updates the
        history of a security token to keep track of previous uses
        @param _contractAddress The smart contract address
        @param _contractIndex The array index of the contract proposal
    */

    function updateContractReputation (address _contractAddress, uint8 _contractIndex) public returns (bool success);
}