pragma solidity ^0.4.18;

import './SafeMath.sol';
import './STO20.sol'; 
import './interfaces/ISecurityToken.sol';
import './interfaces/IERC20.sol';

/**
 * @dev Highly Recommended - Only a sample STO Contract Not used for mainnet !!
 */

contract STOContract is STO20 {

    using SafeMath for uint256;
    string public VERSION = "1";

    ISecurityToken public SecurityToken;
    IERC20 public POLY;
    uint256 public rateInPoly = 100;        // Test figure  In 100 POLY contributor will get 1 Security Token
    address public securityTokenAddress;
    address public owner;

    // Notifications
    event LogBoughtSecurityToken(address indexed _contributor, uint256 _ployContribution, uint256 _timestamp);  

    function STOContract(address _polyTokenAddres) public {
        POLY = IERC20(_polyTokenAddres);
        owner = msg.sender;
    }

     /** 
     * @dev Initializes the STO with certain params
     * @dev _tokenAddress Address of the security token
     * @param _startTime Given in UNIX time this is the time that the offering will begin
     * @param _endTime Given in UNIX time this is the time that the offering will end 
     */
    function securityTokenOffering(
        address _tokenAddress, 
        uint256 _startTime, 
        uint256 _endTime
        ) external
    {   
        require(owner == msg.sender);
        require(_tokenAddress != address(0));
        securityTokenAddress = _tokenAddress;
        SecurityToken = ISecurityToken(_tokenAddress);
        startTime = _startTime;
        endTime = _endTime;
        
    }

    /**
     * @dev `buySecurityTokenWithPoly` Facilitate the buying of SecurityToken in exchange of POLY
     * @param _polyContributed Amount of POLY contributor want to invest.
     * @return bool
     */
    function buySecurityTokenWithPoly(uint256 _polyContributed) public returns(bool) {   
        require(_polyContributed > 0);
        uint256 _amountOfSecurityTokens = _polyContributed.div(rateInPoly);
        require(SecurityToken.issueSecurityTokens(msg.sender, _amountOfSecurityTokens, _polyContributed));
        LogBoughtSecurityToken(msg.sender, _polyContributed, now);
        return true;
    }
     
}