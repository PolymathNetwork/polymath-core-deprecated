pragma solidity ^0.4.15;

import './SafeMath.sol';
import './interfaces/IERC20.sol';

/// Basic ERC20 token contract implementation.
/// Based on OpenZeppelin's StandardToken.
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;
    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    function approve(address _spender, uint256 _value) public returns (bool) {
      // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
      if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
        revert();
      }
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
    }

    /// Function to check the amount of tokens that an owner allowed to a spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }


    /// Gets the balance of the specified address.
    function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
    }

    /// Transfer token to a specified address.
    function transfer(address _to, uint256 _value) public returns (bool) {
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }

    /// Transfer tokens from one address to another.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
      uint256 _allowance = allowed[_from][msg.sender];
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = _allowance.sub(_value);
      Transfer(_from, _to, _value);
      return true;
    }
}
