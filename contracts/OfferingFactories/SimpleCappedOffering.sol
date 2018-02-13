pragma solidity ^0.4.18;

//import '../SecurityTokenMOCK.sol';
import '../interfaces/ISecurityToken.sol';
import '../interfaces/IERC20.sol';
import '../SafeMath.sol';

contract SimpleCappedOffering {

    using SafeMath for uint256;
    string public VERSION = "1";

    ISecurityToken public SecurityToken;

    uint256 public maxPoly;                   // Maximum Poly limit raised by the offering contract
    uint256 public polyRaised;                // Variable to track the poly raised
    uint256 public startTime;                 // Unix timestamp to start the offering
    uint256 public endTime;                   // Unix timestamp to end the offering
    uint256 public exchangeRatePolyToken;     // Fix rate of 1 security token in terms of POLY

    uint256 public securityTokensSold;        // Amount of security tokens sold through the STO

    /////////////
    // Constants
    /////////////

    uint256 public constant DECIMALSFACTOR = 10**uint256(18);

    uint256 public constant TOKENS_MAX_TOTAL          = 1000000 * DECIMALSFACTOR;  // 100%
    uint256 public constant TOKENS_STO                =  500000 * DECIMALSFACTOR;  //  50%
    uint256 public constant TOKENS_FOUNDERS           =  200000  * DECIMALSFACTOR; //  20%
    uint256 public constant TOKENS_EARLY_INVESTORS    =  200000  * DECIMALSFACTOR; //  20%
    uint256 public constant TOKENS_ADVISORS           =  100000  * DECIMALSFACTOR; //  10%

    ///////////////
    // MODIFIERS //
    ///////////////

    modifier onlyDuringSale() {
          require(hasStarted() && !hasEnded());
          _;
      }

    modifier onlyAfterSale() {
        // require finalized is stronger than hasSaleEnded
        require(hasEnded());
        _;
    }

    ////////////
    // EVENTS //
    ////////////

    event LogBoughtSecurityToken(address indexed _contributor, uint256 _ployContribution, uint256 _timestamp);

    /**
     * @dev Constructor A new instance of the capped offering contract get launch
     * everytime when the constructor called by the factory contract
     * @param _startTime Unix timestamp to start the offering
     * @param _endTime Unix timestamp to end the offering
     * @param _exchangeRatePolyToken Price of one security token in terms of poly
     * @param _maxPoly Maximum amount of poly issuer wants to collect
     * @param _securityToken Address of the security token
     */

    function SimpleCappedOffering(uint256 _startTime, uint256 _endTime, uint256 _exchangeRatePolyToken, uint256 _maxPoly, address _securityToken) public {
      require(_startTime >= now);
      require(_endTime > _startTime);
      require(_exchangeRatePolyToken > 0);
      require(_securityToken != address(0));

      //TOKENS_MAX_TOTAL MUST BE equal to all other token token allocations combined
      require(TOKENS_STO.add(TOKENS_FOUNDERS).add(TOKENS_EARLY_INVESTORS).add(TOKENS_ADVISORS) == TOKENS_MAX_TOTAL);

      startTime = _startTime;
      endTime = _endTime;
      exchangeRatePolyToken = _exchangeRatePolyToken;
      maxPoly = _maxPoly;
      SecurityToken = ISecurityToken(_securityToken);
    }

    /**
     * @dev `buy` Facilitate the buying of SecurityToken in exchange of POLY
     * @param _polyContributed Amount of POLY contributor want to invest.
     * @return bool
     */
    function buy(uint256 _polyContributed) public onlyDuringSale returns(bool) {
        require(_polyContributed > 0);
        require(validPurchase(_polyContributed));
        uint256 _amountOfSecurityTokens = _polyContributed.mul(exchangeRatePolyToken).div(10 ** (18 - uint(SecurityToken.decimals())));

        // Make sure we don't sell more tokens than those available to the STO
        // TBD change this so we can sell the difference.
        require (securityTokensSold.add(_amountOfSecurityTokens) <= TOKENS_STO);

        require(SecurityToken.issueSecurityTokens(msg.sender, _amountOfSecurityTokens, _polyContributed));

        polyRaised = polyRaised.add(_polyContributed);
        securityTokensSold = securityTokensSold.add(_amountOfSecurityTokens); //Keep track of tokens sold

        LogBoughtSecurityToken(msg.sender, _polyContributed, now);

        return true;
    }

    /**
     * @dev Use to validate the poly contribution
     * If issuer sets the capping over the offering contract then raised amount should
     * always less than or equal to the maximum amount set (maxPoly)
     * @param _polyContributed Amount of POLY contributor want to invest
     * @return bool
     */
    function validPurchase(uint256 _polyContributed) internal view returns(bool) {
        bool reachedCap = maxPoly > 0 && polyRaised.add(_polyContributed) <= maxPoly;
        return (reachedCap);
    }

    //
    //Helper functions for onlyDuringSale / onlyAfterSale modifiers
    //

    // @return true if STO has ended
    function hasEnded() public constant returns (bool) {
      return now > endTime;
    }

    // @return true if STO has started
    function hasStarted() public constant returns (bool) {
      return now >= startTime;
    }

}
