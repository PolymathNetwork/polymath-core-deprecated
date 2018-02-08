pragma solidity ^0.4.18;

import './SimpleCappedOffering.sol';
import '../interfaces/IOfferingFactory.sol';

/**
 * @dev Highly Recommended - Only a sample STO Contract Not used for mainnet !!
 */

contract SimpleCappedOfferingFactory is IOfferingFactory {

    using SafeMath for uint256;
    string public VERSION = "1";

    ISecurityToken public SecurityToken;

    uint256 public maxPoly;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public fxPolyToken;

    address public owner;

    function SimpleCappedOfferingFactory() public {
        owner = msg.sender;
    }

    function createOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, address _securityToken) public returns (address) {
      return new SimpleCappedOffering(_startTime, _endTime, _polyTokenRate, _securityToken);
    }


}
