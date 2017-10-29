pragma solidity ^0.4.15;
/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
contract IERC20 {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function approve(address _spender, uint256 _value) returns (bool success);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
// An ERC20 token standard faucet
/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
      return c;
    }
    function div(uint256 a, uint256 b) internal returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }
    function sub(uint256 a, uint256 b) internal returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    function add(uint256 a, uint256 b) internal returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
      return a >= b ? a : b;
    }
    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
      return a < b ? a : b;
    }
    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
      return a >= b ? a : b;
    }
    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
      return a < b ? a : b;
    }
}
/// Basic ERC20 token contract implementation.
/// Based on OpenZeppelin's StandardToken.
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;
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
contract PolyToken is ERC20 {
    uint256 public totalSupply = 1000000;
    string public name = 'Polymath Network';
    uint8 public decimals = 18;
    string public symbol = 'POLY';
    /* Token faucet - Not part of the ERC20 standard */
    function getTokens (uint256 _amount) {
      balances[msg.sender] += _amount;
      totalSupply += _amount;
    }
}
