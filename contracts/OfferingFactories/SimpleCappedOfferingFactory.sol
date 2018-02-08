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

    uint256 public fee = 100;
    uint8 public quorum = 10;
    uint256 public vestingPeriod = 8888888;
    bytes32 public description = "Capped";
    uint256 public fxPolyToken;

    address public owner;

    function SimpleCappedOfferingFactory() public {
        owner = msg.sender;
    }

    function createOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, address _securityToken) public returns (address) {
      return new SimpleCappedOffering(_startTime, _endTime, _polyTokenRate, _securityToken);
    }

    function getUsageDetails() view public returns (uint256, uint8, uint256, address, bytes32) {
      return (fee, quorum, vestingPeriod, owner, description);
    }

}
