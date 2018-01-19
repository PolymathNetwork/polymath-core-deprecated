pragma solidity ^0.4.18;

contract STO20 {

    uint256 public startTime;
    uint256 public endTime;
    uint256 public maxPoly;
    address public securityTokenAddress;

    modifier onlyST() {
        require(msg.sender == securityTokenAddress);
        _;
    }
    
    /** 
     * @dev Initializes the STO with certain params
     * @param _startTime Given in UNIX time this is the time that the offering will begin
     * @param _endTime Given in UNIX time this is the time that the offering will end 
     */
    function securityTokenOffering(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyST returns(bool) 
    {
        startTime = _startTime;
        endTime = _endTime;
        return true;
    }

}
