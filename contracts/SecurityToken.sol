pragma solidity ^0.4.15;

import './Ownable.sol';
import './ERC20.sol';

// TODO: Split into security token registry and security token

contract SecurityToken is ERC20 {

    // ERC20 Fields
    string public version = '0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;

    // Accreditation
    struct Accreditation {
      string country; // i.e. CA: 1, US: 2
      uint8 level; // 1, 2, 3, 4
    }
    mapping(address => Accreditation) public accreditations;

    // Compliance Templates proposed
    struct Template {
      address delegate;
      bytes32 template;
      uint256 fee;
    }
    mapping(address => Template) public templates;

    // Legal delegate
    address public delegate;

    // Whitelist of investors
    mapping(address => bool) public investors;

    // Issuance template applied
    string public issuanceTemplate;

    // Issuance tasks completed
    struct Task {
      address assignedTo;
      uint8 fee;
      bool completed;
    }
    mapping(uint8 => Task) public issuanceProcess;

    // Notifications
    event LOG_NewInvestor(address indexed investorAddress, address indexed by);
    event LOG_DelegateSet(address indexed delegateAddress);
    event LOG_TemplateProposal(address delegateAddress, uint256 bid, bytes32 template);
    event LOG_NewSecurityTokenCreated (address indexed securityTokenAddress, string indexed securityTokenTicker, uint256 bounty, uint256 expiry); 


    /// Set default security token parameters
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    function SecurityToken(string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner) {
      owner = _owner;
      name = _name;
      symbol = _ticker;
      decimals = _decimals;
      totalSupply = _totalSupply;
      balances[_owner] = _totalSupply;
      delegate = _owner;
    }

    modifier onlyOwner() {
      require (msg.sender == owner);
      _;
    }

    modifier onlyDelegate() {
      require(delegate == msg.sender);
      _;
    }

    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && balances[msg.sender] >= _value && _value > 0) {
        return super.transfer(_to, _value);
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

    /// Assign a legal delegate to the security token issuance
    /// @param _delegate Address of legal delegate
    /// @return bool success
    function setDelegate(address _delegate) onlyOwner returns (bool success) {
      require(delegate == 0x0);
      delegate = _delegate;
      LOG_DelegateSet(_delegate);
      return true;
    }

    /// Assign a legal delegate to the security token issuance
    /// @param _address Address of legal delegate
    /// @return bool success
    function whitelistInvestor(address _address) onlyDelegate returns (bool success) {
      investors[_address] = true;
      LOG_NewInvestor(_address, msg.sender);
      return true;
    }

    /// Allow transfer of any accidentally sent ERC20 tokens to the contract owner
    /// @param _tokenAddress Address of ERC20 token
    /// @param _amount Amount of tokens to send
    /// @return bool success
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
      return ERC20(_tokenAddress).transfer(owner, _amount);
    }

    // New compliance template proposal
    function proposeIssuanceTemplate(address _delegate, bytes32 _templateId, uint256 _bid) {
      templates[_delegate] = Template(_delegate, _templateId, _bid);
      LOG_TemplateProposal(_delegate, _bid, _templateId);
    }

    /// Apply an approved issuance template to the security token
    /// @param _templateId Issuance template ID
    /// @return bool success
    function setIssuanceTemplate(string _templateId) onlyOwner returns (bool success) {
      issuanceTemplate = _templateId;
      return true;

    //need to add in two function calls, add bounty for developers and add bounty for legal delegate. it transfers POLY tokens, so needs to be linked to ropsten deployed POLY
    //need to have a propose bid function so devs and legals can propose what they will do it for 
    //want to only assign delegate once, but build in an expiry so you can reassign 

    }
}
