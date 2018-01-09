pragma solidity ^0.4.18;

interface ISTO {

    /* @dev Initializes the STO with certain params
    @param _tokenAddress The Security Token address
    @param _startTime Given in UNIX time this is the time that the offering will begin
    @param _endTime Given in UNIX time this is the time that the offering will end */
    function securityTokenOffering(
        address _tokenAddress,
        uint256 _startTime,
        uint256 _endTime
    ) external;

}
