pragma solidity ^0.4.18;

interface IOfferingFactory {

  /**
   * @dev It facilitate the creation of the STO contract with essentials parameters
   * @param _startTime Unix timestamp to start the offering
   * @param _endTime Unix timestamp to end the offering
   * @param _polyTokenRate Price of one security token in terms of poly
   * @param _maxPoly Maximum amount of poly issuer wants to collect
   * @param _securityToken Address of the security token 
   * @return address Address of the new offering instance
   */
  function createOffering(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _polyTokenRate,
    uint256 _maxPoly,
    address _securityToken
    ) public returns (address);

  /**
   * @dev `getUsageDetails` is a function to get all the details on factory usage fees
   * @return uint256 fee, uint8 quorum, uint256 vestingPeriod, address owner, string description
   */
  function getUsageDetails() view public returns (uint256, uint8, uint256, address, bytes32);

}
