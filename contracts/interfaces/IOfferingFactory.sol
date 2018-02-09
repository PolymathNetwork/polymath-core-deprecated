pragma solidity ^0.4.18;

interface IOfferingFactory {

  /**
   * @dev `createOffering` creates a new Offering contract from the factory
   */
  function createOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, uint256 _maxPoly, address _securityToken) public returns (address);

  /**
   * @dev `getUsageDetails` is a function to get all the details on template usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, string description
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, bytes32);

}
