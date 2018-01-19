pragma solidity ^0.4.18;

import './SafeMath.sol';
import './STO20.sol'; 
import './interfaces/ISecurityToken.sol';
import './interfaces/IERC20.sol';

contract STOContract is STO20 {

    using SafeMath for uint256;
    string public VERSION = "1";
    ISecurityToken public SecurityToken;
    IERC20 public POLY;
    uint256 public rateInPoly = 100;        // Test figure
    
    event LogBoughtSecurityToken(address indexed _contributor, uint256 _ployContribution, uint256 _timestamp);  

    function STOContract(address _polyTokenAddres, address _securityTokenAddress) public {
        POLY = IERC20(_polyTokenAddres);
        require(_securityTokenAddress != address(0));
        securityTokenAddress = _securityTokenAddress;
        SecurityToken = ISecurityToken(_securityTokenAddress);
        maxPoly = 100000;
    }

    function buySecurityToken(uint256 _polyContributed) public returns(bool) {   
        require(_polyContributed > 0);
        uint256 _amountOfSecurityTokens = _polyContributed.div(rateInPoly);
        require(SecurityToken.issueSecurityTokens(msg.sender, _amountOfSecurityTokens, _polyContributed));
        LogBoughtSecurityToken(msg.sender, _polyContributed, now);
        return true;
    }  


     
}