/*
  The Polymath Security Token Standard
.*/

pragma solidity ^0.4.15;

import './ERC20.sol';
import './Ownable.sol';

contract SecurityToken is ERC20, Ownable {

    string public version = '0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public partners;

    modifier onlyPartners() {
      require(partners[msg.sender]);
      _;
    }

    /** Constructor **/
    function SecurityToken(string _name, string _ticker, uint8 _decimals, uint256 _totalSupply) {
      require(bytes(_name).length > 0 && bytes(_ticker).length > 0); // Validate input
      name = _name;
      symbol = _ticker;
      decimals = _decimals;
      totalSupply = _totalSupply;
      balances[msg.sender] = _totalSupply;
      partners[msg.sender] = true;
    }

    // Allow transfer of Security Tokens to other whitelisted accounts
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (whitelisted[_to] && balances[msg.sender] >= _value && _value > 0) {
        return super.transfer(_to, _value);
      } else {
        return false;
      }
    }

    // Allow transfer of Security Tokens from/to other whitelisted accounts
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (whitelisted[_to] && whitelisted[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        return super.transferFrom(_from, _to, _value);
      } else {
        return false;
      }
    }

    // Allow withdrawals of Security Tokens from other whitelisted addresses
    function approve(address _spender, uint256 _value) returns (bool success) {
      if (whitelisted[_spender]) {
        return super.approve(_spender, _value);
      } else {
        return false;
      }
    }

    // Add a Polymath Partner (to add investors to the whitelist)
    function addPartner(address _address) onlyOwner {
      partners[_address] = true;
    }

    // Add an investor to the whitelist (to allow buy/sell the security)
    function whitelistInvestor(address _address) onlyPartners {
      whitelisted[_address] = true;
    }
}
