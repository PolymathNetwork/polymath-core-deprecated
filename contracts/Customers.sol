pragma solidity ^0.4.15;

import './Ownable.sol';

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by KYC providers.
*/

contract Customers is Ownable {

  // A Polymath Customer
  struct Customer {
    bytes8 jurisdiction;
    uint8 role;
    bool verified;
    bool accredited;
    bool flagged;
    bytes32 proof;
    uint256 expires;
  }
  // Mapping of customer address to details
  mapping(address => Customer) public customers;

  // KYC Provider
  struct Provider {
    string name;
    bytes32 application;
    bool approved;
    uint256 expires;
  }
  // Mapping of provider address to details
  mapping(address => Provider) public providers;

  // Notifications
  event NewInvestor(address customer, bytes32 jurisdiction, bool accredited);
  event NewProvider(address providerAddress, string name, bytes32 application, bool approved);

  /// Verify a customer
  /// @param _customer The customer's public key address
  /// @param _jurisdiction The jurisdiction code of the customer
  /// @param _role The type of customer - investor:1 or issuer:2
  /// @param _accredited Whether the customer is accredited or not (only applied to investors)
  /// @param _proof The SHA256 hash of the documentation provided to prove identity
  /// @param _expires The time the KYC verification expires
  function verifyCustomer(address _customer, bytes8 _jurisdiction, uint8 _role, bool _accredited, bytes32 _proof, uint256 _expires) {
    require(providers[msg.sender].approved);
    customers[_customer].jurisdiction = _jurisdiction;
    customers[_customer].role = _role;
    customers[_customer].accredited = _accredited;
    customers[_customer].proof = _proof;
    customers[_customer].expires = _expires;
    NewCustomer(_customer, _jurisdiction, _accredited);
  }

  /// Allow new provider applications
  /// @param _providerAddress The provider's public key address
  /// @param _name The provider's name
  /// @param _application A SHA256 hash of the application document
  function newProvider(address _providerAddress, string _name, bytes32 _application) {
    require(_providerAddress != address(0));
    require(providers[_providerAddress] == 0);
    providers[_providerAddress].name = _name;
    providers[_providerAddress].application = _application;
    providers[_providerAddress].approved = false;
    NewProvider(_providerAddress, _name, _application, false);
  }

  /// Approve or reject a new provider application
  /// @param _providerAddress The provider's public key address
  /// @param _approved Is the provider approved or not
  /// @param _expires Timestamp the delegate is valid on Polymath until
  function approveProvider(address _providerAddress, bool _approved, uint256 _expires) onlyOwner {
    require(_expires >= now);
    if (_approved == true) {
      provider[_providerAddress].expires = _expires;
      provider[_providerAddress].approved = true;
      NewProvider(_providerAddress, _name, _application, true);
    } else {
      delete provider[_providerAddress];
    }
  }

}
