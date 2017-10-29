// An ERC20 token standard faucet
pragma solidity ^0.4.15;

import './ERC20.sol';

contract PolyToken is ERC20 {

    uint256 public totalSupply = 1000000;
    string public name = 'Polymath Network';
    uint8 public decimals = 18;
    string public symbol = 'POLY';

    /// Gets the balance of the specified address.
    function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
    }

    /* Token faucet - Not part of the ERC20 standard */
    function getTokens (uint256 _amount) {
      balances[msg.sender] += _amount;
      totalSupply += _amount;
    }

}
