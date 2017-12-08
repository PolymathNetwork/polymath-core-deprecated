pragma solidity ^0.4.18;

contract ICustomers {
  /** @dev Allow new provider applications
    @param _providerAddress The provider's public key address
    @param _name The provider's name
    @param _details A SHA256 hash of the new providers details
    @param _fee The fee charged for customer verification */
  function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);

  /** @dev Allow new investor applications
     @param _jurisdiction The jurisdiction code of the customer
     @param _provider The provider selected by the customer to do verification
     @param _role The type of customer - investor:1, issuer:2, delegate:3
     @param _proof The SHA256 hash of the documentation provided to prove identity */
  function newCustomer(bytes32 _jurisdiction, address _provider, uint8 _role, bytes32 _proof) public returns (bool success);

  /** @dev Verify an investor
    @param _customer The customer's public key address
    @param _jurisdiction The jurisdiction code of the customer
    @param _role The type of customer - investor:1, issuer:2, delegate:3, marketmaker:4,
    @param _accredited Whether the customer is accredited or not (only applied to investors)
    @param _proof The SHA256 hash of the documentation provided to prove identity
    @param _expires The time the verification expires */
  function verifyCustomer(
      address _customer,
      bytes32 _jurisdiction,
      uint8 _role,
      bool _accredited,
      bytes32 _proof,
      uint256 _expires
  ) public returns (bool success);

  /// Getter function for attestations
  function getCustomer(address _provider, address _customer) public constant returns (
    bytes32,
    bool,
    uint8,
    bool,
    uint256
  );
}
