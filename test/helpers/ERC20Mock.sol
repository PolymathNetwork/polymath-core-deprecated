pragma solidity ^0.4.15;

import '../../contracts/ERC20.sol';

contract ERC20Mock is ERC20 {
    function assign(address _account, uint _balance) {
        balances[_account] = _balance;
    }
}
