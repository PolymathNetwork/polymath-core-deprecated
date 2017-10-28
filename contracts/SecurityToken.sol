pragma solidity ^0.4.15;

import './ERC20.sol';
import './PolyToken.sol';
import './Compliance.sol';
import './SecurityTokens.sol';

contract SecurityToken is ERC20 {

    string public version = '0.1';

    // Compliance Template Proposal
    struct ComplianceTemplate {
      address creator;
      bytes32 securityType;
      bytes32 complianceProcess;
      bytes8 issuerJurisdiction;
      bytes8[] restrictedJurisdictions;
      uint256 templateValidUntil;
      uint256 proposalValidUntil;
      uint256 estimatedTimeToComplete;
      uint256 vestingPeriod;
      uint256 delegateFee;
    }
    // Mapping of Legal Delegate addresses to proposed ComplianceTemplates
    mapping(address => ComplianceTemplate) public complianceTemplateProposals;

    // Legal delegate
    address public delegate;

    // Proof of compliance process (merkle root hash)
    bytes32 public complianceProof;

    // STO address
    address public STO;

    // KYC Provider
    address public KYC;

    // Security Token Whitelisted Investors
    mapping(address => uint256) public whitelist;

    // Instance of the POLY token contract
    PolyToken POLY = PolyToken(0x0f54D1617eCb696e267db81a1956c24373254785);

    // Instance of the Polymath customers contract
    Compliance KYC = Compliance(0x0f54D1617eCb696e267db81a1956c24373254785);

    // Notifications
    event LogDelegateSet(address indexed delegateAddress);
    event LogComplianceTemplateProposal(address indexed delegateAddress);
    event LogSecurityTokenOffering(address indexed STOAddress);
    event LogNewComplianceProof(bytes32 merkleRoot, bytes32 complianceProof);

    modifier onlyOwner() {
      require (msg.sender == owner);
      _;
    }

    modifier onlyDelegate() {
      require(delegate == msg.sender);
      _;
    }

    /// Propose a new compliance template for the Security Token
    /// @param _delegate Legal Delegate public ethereum address
    /// @param _complianceTemplate Compliance Template being proposed
    /// @return bool success
    function proposeComplianceTemplate(address _delegate, ComplianceTemplate _complianceTemplate) returns (bool success){
      require(complianceTemplateProposals[_delegate] == 0);
      complianceTemplateProposals[_delegate] = _complianceTemplate;
      LogComplianceTemplateProposal(_delegate);
      return true;
    }

    /// Accept a Delegate's proposal
    /// @param _delegate Legal Delegates public ethereum address
    /// @return bool success
    function setDelegate(address _delegate) onlyOwner {
      require(delegate == address(0));
      require(complianceTemplateProposals[_delegate].proposalValidUntil > now);
      require(complianceTemplateProposals[_delegate].templateValidUntil > now);
      if (POLY.balances[this] < complianceTemplateProposals[_delegate].fee) {
        revert(); // Add reason when this is implemented https://github.com/ethereum/solidity/issues/1686#issuecomment-328181514
      }
      delegate = _delegate;
      LogDelegateSet(_delegate);
      return true;
    }

    /// Update compliance proof
    /// @param _newMerkleRoot New merkle root hash of the compliance proofs
    /// @param _complianceProof Compliance proof hash
    /// @return bool success
    function updateComplianceProof(bytes32 _newMerkleRoot, bytes32 _complianceProof) returns (bool success) {
      require(msg.sender == owner || msg.sender == delegate);
      complianceProof = _newMerkleRoot;
      LogNewComplianceProof(_newMerkleRoot, _complianceProof);
      return true;
    }

    /// Set the STO contract address
    /// @param _STOaddress Ethereum address of the STO contract
    /// @return bool success
    function setSTO(address _STO) onlyDelegate returns (bool success) {
      require(complianceProof != 0);
      require(_STO = address(0));
      STO = _STO;
      LogSecurityTokenOffering(_STO);
      return true;
    }

    /// Set the KYC provider
    /// @param _KYCProvider Name of the KYC provider
    /// @return bool success
    function setKYC(string _KYC) onlyOwner returns (bool success) {
      require(_KYC)
      require(complianceProof != 0);
      require(_KYC.length > 1);
      KYC = _KYC;
      LogSetKYC(_KYC);
      return true;
    }

    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && balances[msg.sender] >= _value && _value > 0) {
        return super.transfer(_to, _value); //super gives access to .transfer in parent contract
      } else {
        return false;
      }
    }

    /// Allows contracts to transfer tokens on behalf of token holders
    /// @param _from Address to transfer tokens from
    /// @param _to Address to send tokens to
    /// @param _value Number of tokens to transfer
    /// @return bool success
    /// TODO: eliminate msg.sender for 0x
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && investors[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        return super.transferFrom(_from, _to, _value);
      } else {
        return false;
      }
    }

    /// Approve transfer of tokens manually
    /// @param _spender Address to approve transfer to
    /// @param _value Amount of tokens to approve for transfer
    /// @return bool success
    function approve(address _spender, uint256 _value) returns (bool success) {
      if (investors[_spender]) {
        return super.approve(_spender, _value);
      } else {
        return false;
      }
    }

    /// Allow transfer of any accidentally sent ERC20 tokens to the contract owner
    /// @param _tokenAddress Address of ERC20 token
    /// @param _amount Amount of tokens to send
    /// @return bool success
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
      return ERC20(_tokenAddress).transfer(owner, _amount);
    }
}
