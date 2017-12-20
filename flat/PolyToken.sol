pragma solidity ^0.4.18;

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
 POLY token faucet is only used on testnet for testing purposes
 !!!! NOT INTENDED TO BE USED ON MAINNET !!!
*/




contract PolyToken is IERC20 {

    using SafeMath for uint256;
    uint256 public totalSupply = 1000000;
    string public name = "Polymath Network";
    uint8 public decimals = 18;
    string public symbol = "POLY";

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Token faucet - Not part of the ERC20 standard */
    function getTokens(uint256 _amount, address _recipient) public returns (bool) {
        balances[_recipient] += _amount;
        totalSupply += _amount;
        return true;
    }

    /* @dev send `_value` token to `_to` from `msg.sender`
    @param _to The address of the recipient
    @param _value The amount of token to be transferred
    @return Whether the transfer was successful or not */
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /* @dev send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
      @param _from The address of the sender
      @param _to The address of the recipient
      @param _value The amount of token to be transferred
      @return Whether the transfer was successful or not */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];
        require(_allowance >= _value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /* @param _owner The address from which the balance will be retrieved
    @return The balance */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* @dev `msg.sender` approves `_spender` to spend `_value` tokens
    @param _spender The address of the account able to transfer the tokens
    @param _value The amount of tokens to be approved for transfer
    @return Whether the approval was successful or not */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /* @param _owner The address of the account owning tokens
    @param _spender The address of the account able to transfer the tokens
    @return Amount of remaining tokens allowed to spent */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}