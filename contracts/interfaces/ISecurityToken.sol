  pragma solidity ^0.4.18;

  interface ISecurityToken {

    /* @dev Set default security token parameters
    @param _name Name of the security token
    @param _ticker Ticker name of the security
    @param _totalSupply Total amount of tokens being created
    @param _owner Ethereum address of the security token owner
    @param _maxPoly Amount of POLY being raised
    @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    @param _quorum Percent of initial investors required to freeze POLY raise
    @param _polyTokenAddress Ethereum address of the POLY token contract
    @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
    @param _polyComplianceAddress Ethereum address of the PolyCompliance contract */
    function SecurityToken(
        string _name,
        bytes8 _ticker,
        uint256 _totalSupply,
        address _owner,
        uint256 _maxPoly,
        uint256 _lockupPeriod,
        uint8 _quorum,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress
    ) public;

    /* @dev `selectTemplate` Select a proposed template for the issuance
    @param _templateIndex Array index of the delegates proposed template
    @return bool success */
    function selectTemplate(uint8 _templateIndex) public returns (bool success);

    /* @dev Update compliance proof hash for the issuance
    @param _newMerkleRoot New merkle root hash of the compliance Proofs
    @param _complianceProof Compliance Proof hash
    @return bool success */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public returns (bool success);

    /* @dev Select an security token offering proposal for the issuance
    @param _offeringProposalIndex Array index of the STO proposal
    @param _startTime Start of issuance period
    @param _endTime End of issuance period
    @return bool success */
    function selectOfferingProposal (
        uint8 _offeringProposalIndex,
        uint256 _startTime,
        uint256 _endTime
    ) public returns (bool success);

    /* @dev Add a verified address to the Security Token whitelist
    @param _whitelistAddress Address attempting to join ST whitelist
    @return bool success */
    function addToWhitelist(uint8 KYCProviderIndex, address _whitelistAddress) public returns (bool success);

    /* @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO developer at appropriate times
    @return bool success */
    function withdrawPoly() public returns (bool success);

    /* @dev Vote to freeze the fee of a certain network participant
    @param _recipient The fee recipient being protested
    @return bool success */
    function voteToFreeze(address _recipient) public returns (bool success);

    /* @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
    @param _contributor The address of the person whose contributing
    @param _amountOfSecurityTokens The amount of ST to pay out.
    @param _polyContributed The amount of POLY paid for the security tokens. */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public returns (bool success);

    /// Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address);

    /* @dev Trasfer tokens from one address to another
    @param _to Ethereum public address to transfer tokens to
    @param _value Amount of tokens to send
    @return bool success */
    function transfer(address _to, uint256 _value) public returns (bool success);

    /* @dev Allows contracts to transfer tokens on behalf of token holders
    @param _from Address to transfer tokens from
    @param _to Address to send tokens to
    @param _value Number of tokens to transfer
    @return bool success */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /* @param _owner The address from which the balance will be retrieved
    @return The balance */
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /* @dev Approve transfer of tokens manually
    @param _spender Address to approve transfer to
    @param _value Amount of tokens to approve for transfer
    @return bool success */
    function approve(address _spender, uint256 _value) public returns (bool success);

    /* @param _owner The address of the account owning tokens
    @param _spender The address of the account able to transfer the tokens
    @return Amount of remaining tokens allowed to spent */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  }
