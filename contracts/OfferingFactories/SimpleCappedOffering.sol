pragma solidity ^0.4.18;

import '../interfaces/ISecurityToken.sol';
import '../interfaces/IERC20.sol';
import '../SafeMath.sol';

contract SimpleCappedOffering {

    using SafeMath for uint256;
    string public VERSION = "1";

    ISecurityToken public SecurityToken;

    uint256 public maxPoly;
    uint256 public polyRaised;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public fxPolyToken;

    // Notifications
    event LogBoughtSecurityToken(address indexed _contributor, uint256 _ployContribution, uint256 _timestamp);

    /**
     * @dev Constructor A new instance of the capped offering contract get launch
     * everytime when the constructor called by the factory contract
     * @param _startTime Unix timestamp to start the offering
     * @param _endTime Unix timestamp to end the offering
     * @param _fxPolyToken Price of one security token in terms of poly
     * @param _maxPoly Maximum amount of poly issuer wants to collect
     * @param _securityToken Address of the security token    
     */

    function SimpleCappedOffering(uint256 _startTime, uint256 _endTime, uint256 _fxPolyToken, uint256 _maxPoly, address _securityToken) public {
      require(_startTime > now);
      require(_endTime > _startTime);
      require(_fxPolyToken > 0);
      require(_securityToken != address(0));
      startTime = _startTime;
      endTime = _endTime;
      fxPolyToken = _fxPolyToken;
      maxPoly = _maxPoly;
      SecurityToken = ISecurityToken(_securityToken);
    }

    /**
     * @dev `buy` Facilitate the buying of SecurityToken in exchange of POLY
     * @param _polyContributed Amount of POLY contributor want to invest.
     * @return bool
     */
    function buy(uint256 _polyContributed) public returns(bool) {
        require(_polyContributed > 0);
        require(validPurchase(_polyContributed));
        uint256 _amountOfSecurityTokens = _polyContributed.div(fxPolyToken);
        require(SecurityToken.issueSecurityTokens(msg.sender, _amountOfSecurityTokens, _polyContributed));
        polyRaised = polyRaised.add(_polyContributed);
        LogBoughtSecurityToken(msg.sender, _polyContributed, now);
        return true;
    }

    function validPurchase(uint256 _polyContributed) internal view returns(bool) {
        if (maxPoly > 0 && maxPoly < (polyRaised + _polyContributed)) {
            return false;
        } else {
            return true;
        }
    }

}
