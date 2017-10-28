pragma solidity ^0.4.15;

import './Ownable.sol';


/*
  Polymath compliance templates protocol is used to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol ensures security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/

contract SecurityTokenOfferingRegistry is Ownable {

  // Service provider details
  struct Contract {
    address contractAddress;
    uint256 fee;
    bool approved;
  }

  // Service provider registry
  mapping(address => Contract) public offeringContracts;

  // Notifications
  event STO_Created(address _contractAddress, uint256 _fee);
  event STO_Approved(address _contractAddress, uint256 _fee);

  /// Allow new security token offering contract creations
  /// @param _contractAddress The security token offering contract's public key address
  /// @param _fee The fee charged for the services provided in POLY
  function newSecurityOffering(address _contractAddress, uint256 _fee) {
    require(_contractAddress != address(0));
    offeringContracts[_contractAddress] = Contract(_contractAddress, _fee, false);
    STO_Created(_contractAddress, _fee);
  }

  /// Approve or reject a security token offering contract application
  /// @param _offeringAddress The legal delegate's public key address
  /// @param _approved Whether the security token offering contract was approved or not
  /// @param _fee the fee to perform the task
  function approveOfferingContract(address _offeringAddress, bool _approved, uint256 _fee) onlyOwner {
    require(_offeringAddress != address(0));
   // require(offeringContracts[_offeringAddress]); this is not a completed require statement - dk
    if (_approved == true) {
      offeringContracts[_offeringAddress].approved = true;
      offeringContracts[_offeringAddress].fee = _fee;
      STO_Approved(_offeringAddress, _fee);
    } else {
     // offeringContracts[_offeringAddress] = 0x0; - tuffle compiler error, commented out until working on this contract - dk
    }
  }

}
