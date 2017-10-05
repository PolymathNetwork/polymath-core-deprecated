pragma solidity ^0.4.15;

import './Ownable.sol';
import './ERC20.sol';

contract SecurityToken is Ownable, ERC20 {

    string public version = '0.1';
    string public name;
    string public symbol;
    uint8 public decimals;

    address public delegate;
    mapping(address => bool) public investors;

    string public complianceTemplate;
    mapping(string => bool) public complianceRequirements;

    event LogNewInvestor(address indexed investor, address indexed by);
    event LogNewRegulator(address indexed regulator, string desc);

    function SecurityToken(string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner) {
      owner = _owner;
      name = _name;
      symbol = _ticker;
      decimals = _decimals;
      totalSupply = _totalSupply;
      balances[_owner] = _totalSupply;
      delegate = _owner;
    }

    modifier onlyDelegate() {
      require(delegate == msg.sender);
      _;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && balances[msg.sender] >= _value && _value > 0) {
        return super.transfer(_to, _value);
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && investors[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        return super.transferFrom(_from, _to, _value);
      } else {
        return false;
      }
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
      if (investors[_spender]) {
        return super.approve(_spender, _value);
      } else {
        return false;
      }
    }

    function setDelegate(address _address, string _desc) onlyOwner returns (bool success) {
      delegate = _address;
      LogNewDelegate(_address, _desc);
      return true;
    }

    function whitelistInvestor(address _address) onlyDelegate returns (bool success) {
      investors[_address] = true;
      LogNewInvestor(_address, msg.sender);
      return true;
    }

    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
      return ERC20(_tokenAddress).transfer(owner, _amount);
    }

    // Set a compliance template
    function setComplianceTemplate(string _templateId) onlyOwner returns (bool success) {
      complianceTemplate = _templateId;
      return true;
    }
}
