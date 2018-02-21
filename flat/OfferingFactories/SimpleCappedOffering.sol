pragma solidity ^0.4.18;

interface ISecurityToken {

   /**
     * @dev `selectTemplate` Select a proposed template for the issuance
     * @param _templateIndex Array index of the delegates proposed template
     * @return bool success
     */
    function selectTemplate(uint8 _templateIndex) public returns (bool success);

    /**
     * @dev Update compliance proof hash for the issuance
     * @param _newMerkleRoot New merkle root hash of the compliance Proofs
     * @param _complianceProof Compliance Proof hash
     * @return bool success
     */
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public returns (bool success);

    /**
     * @dev `selectOfferingFactory` Select an security token offering proposal for the issuance
     * @param _offeringFactoryProposalIndex Array index of the STO proposal
     * @return bool success
     */
    function selectOfferingFactory (
        uint8 _offeringFactoryProposalIndex
    ) public returns (bool success);

    /**
     * @dev Start the offering by sending all the tokens to STO contract
     * @param _startTime Unix timestamp to start the offering
     * @param _endTime Unix timestamp to end the offering
     * @param _polyTokenRate Price of one security token in terms of poly
     * @param _maxPoly Maximum amount of poly issuer wants to collect
     * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
     * @param _quorum Percent of initial investors required to freeze POLY raise
     * @return bool
     */
    function initialiseOffering(uint256 _startTime, uint256 _endTime, uint256 _polyTokenRate, uint256 _maxPoly, uint256 _lockupPeriod, uint8 _quorum) external returns (bool success);

    /**
     * @dev Add a verified address to the Security Token whitelist
     * @param _whitelistAddress Address attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelist(address _whitelistAddress) public returns (bool success);

    /**
     * @dev Add verified addresses to the Security Token whitelist
     * @param _whitelistAddresses Array of addresses attempting to join ST whitelist
     * @return bool success
     */
    function addToWhitelistMulti(address[] _whitelistAddresses) public returns (bool success);

    /**
     * @dev Removes a previosly verified address to the Security Token blacklist
     * @param _blacklistAddress Address being added to the blacklist
     * @return bool success
     */
    function addToBlacklist(address _blacklistAddress) public returns (bool success);

    /**
     * @dev Removes previously verified addresseses to the Security Token whitelist
     * @param _blacklistAddresses Array of addresses attempting to join ST whitelist
     * @return bool success
     */
    function addToBlacklistMulti(address[] _blacklistAddresses) public returns (bool success);

     /**
      * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
      * @return bool success
      */
    function withdrawPoly() public returns (bool success);

    /**
     * @dev Vote to freeze the fee of a certain network participant
     * @param _recipient The fee recipient being protested
     * @return bool success
     */
    function voteToFreeze(address _recipient) public returns (bool success);

    /**
     * @dev `issueSecurityTokens` is used by the STO to keep track of STO investors
     * @param _contributor The address of the person whose contributing
     * @param _amountOfSecurityTokens The amount of ST to pay out.
     * @param _polyContributed The amount of POLY paid for the security tokens.
     */
    function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public returns (bool success);

    /// Get token details
    function getTokenDetails() view public returns (address, address, bytes32, address, address, address);

    /// Get token decimals
    function decimals() view public returns (uint8);
  }

/// ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
interface IERC20 {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function totalSupply() public view returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 *  SafeMath <https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol/>
 *  Copyright (c) 2016 Smart Contract Solutions, Inc.
 *  Released under the MIT License (MIT)
 */

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

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
        uint256 _amountOfSecurityTokens = _polyContributed.div(exchangeRatePolyToken);

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