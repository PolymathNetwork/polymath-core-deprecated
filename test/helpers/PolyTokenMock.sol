pragma solidity ^0.4.15;

import '../../contracts/PolyToken.sol';
import '../../contracts/interfaces/IERC20.sol';

contract PolyToken is IERC20 {
    function assign(address _account, uint _balance) {
        balances[_account] = _balance;
    }
}
