pragma solidity ^0.4.18;

import '../SecurityToken.sol';

/**
 * @title SecurityToken
 * @dev Contract (A Blueprint) that contains the functionalities of the security token
 */

contract SecurityTokenMOCK is SecurityToken {

  function SecurityTokenMOCK(
      string _name,
      string _ticker,
      uint256 _totalSupply,
      uint8 _decimals,
      address _owner,
      uint256 _lockupPeriod,
      uint8 _quorum,
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress
  ) public
  SecurityToken(
        _name,
        _ticker,
        _totalSupply,
        _decimals,
        _owner,
        _lockupPeriod,
        _quorum,
        _polyTokenAddress,
        _polyCustomersAddress,
        _polyComplianceAddress

    )
  {}

  function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public onlyOffering returns (bool success) {

      // Update ST balances (transfers ST from STO to _contributor)
      balances[offering] = balances[offering].sub(_amountOfSecurityTokens);
      balances[_contributor] = balances[_contributor].add(_amountOfSecurityTokens);
      // ERC20 Transfer event
      Transfer(offering, _contributor, _amountOfSecurityTokens);
      // Update the amount of POLY a contributor has contributed and allocated to the owner
      contributedToSTO[_contributor] = contributedToSTO[_contributor].add(_polyContributed);
      allocations[owner].amount = allocations[owner].amount.add(_polyContributed);
      totalAllocated = totalAllocated.add(_polyContributed);
      LogTokenIssued(_contributor, _amountOfSecurityTokens, _polyContributed, now);
      return true;
  }

  /**
   * @dev Start the offering by sending all the tokens to STO contract
   * @return bool
   */
  function initialiseOffering(address _offering) onlyOwner external returns (bool success) {
      require(!hasOfferingStarted);
      hasOfferingStarted = true;
      offering = _offering;
      shareholders[offering] = Shareholder(this, true, 5);
      uint256 tokenAmount = this.balanceOf(msg.sender);
      require(tokenAmount == totalSupply);
      balances[offering] = balances[offering].add(tokenAmount);
      balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
      Transfer(owner, offering, tokenAmount);
      return true;
  }

}
