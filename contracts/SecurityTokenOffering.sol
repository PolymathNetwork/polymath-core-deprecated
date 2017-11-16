pragma solidity ^0.4.15;

contract SecurityTokenOffering {

    uint startTime;
    uint endTime;
    address tokenAddress;
    address funder;

    /// @notice `SecurityTokenOffering` simply sets the start and ending time
    ///  for the token offering period.
    /// @param _startTime Given in UNIX time this is the time that the
    ///  offering will begin
    /// @param _endTime Given in UNIX time this is the time that the
    ///  offering will end
    function SecurityTokenOffering(address _tokenAddress, uint256 _startTime, uint256 _endTime) public {
      tokenAddress = _tokenAddress;
      startTime = _startTime;
      endTime = _endTime;
    }

    /// @notice all SecutiryTokenOfferings have to distribute tokens
    ///  through the fallback function.
    // function() public payable;

}
