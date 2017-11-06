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
  // Provider address => {customer address => Customer}
  mapping(address => mapping(address => Customer)) public customers;

  // KYC Provider
  struct Provider {
    string name;
    bytes32 application;
    bool approved;
    uint256 expires;
  }
  // Provider address => Provider
  mapping(address => Provider) public providers;

  // Notifications
  event NewCustomer(address customer, address provider, bytes32 jurisdiction, uint8 role, bytes32 proof, bool verified);
  event NewProvider(address providerAddress, string name, bytes32 application, bool approved);

  modifier onlyProvider() {
    require(providers[msg.sender].approved == true);
    require(providers[msg.sender].expires > now);
    _;
  }

  /// Allow new investor applications
  /// @param _jurisdiction The jurisdiction code of the customer
  /// @param _provider The provider selected by the customer to do verification
  /// @param _role The type of customer - investor:1 or issuer:2
  /// @param _proof The SHA256 hash of the documentation provided to prove identity
  function newCustomer(bytes8 _jurisdiction, address _provider, uint8 _role, bytes32 _proof) {
    require(providers[_provider].approved);
    require(_role == 1 || _role == 2);
    customers[_provider][msg.sender].jurisdiction = _jurisdiction;
    customers[_provider][msg.sender].role = _role;
    customers[_provider][msg.sender].verified = false;
    customers[_provider][msg.sender].accredited = false;
    customers[_provider][msg.sender].flagged = false;
    customers[_provider][msg.sender].proof = _proof;
    NewCustomer(msg.sender, _provider, _jurisdiction, _role, _proof, false);
  }

  /// Verify an investor
  /// @param _customer The customer's public key address
  /// @param _jurisdiction The jurisdiction code of the customer
  /// @param _role The type of customer - investor:1 or issuer:2
  /// @param _accredited Whether the customer is accredited or not (only applied to investors)
  /// @param _proof The SHA256 hash of the documentation provided to prove identity
  /// @param _expires The time the KYC verification expires
  function verifyCustomer(address _customer, bytes8 _jurisdiction, uint8 _role, bool _accredited, bytes32 _proof, uint256 _expires) onlyProvider {
    require(customers[msg.sender][_customer].verified == false);
    //this is testing that the customer actually picked this KYC provider to review them. 
    //becuase to apply in the first place with one provider, they will are required to set their own role
    //if no role is ever set, they never applied with this specific provider, and it should fail
    require(customers[msg.sender][_customer].role != 0);
    customers[msg.sender][_customer].jurisdiction = _jurisdiction;
    customers[msg.sender][_customer].role = _role;
    customers[msg.sender][_customer].accredited = _accredited;
    customers[msg.sender][_customer].expires = _expires;
    customers[msg.sender][_customer].verified = true;
    //this is very confusing to me, why are we making a new customer? shouldnt we be updating the instance of the customer we have stored in customers? - dk nov 5
    NewCustomer(_customer, msg.sender, _jurisdiction, _role, _proof, true);
  }

  /// Allow new provider applications
  /// @param _providerAddress The provider's public key address
  /// @param _name The provider's name
  /// @param _application A SHA256 hash of the application document
  function newProvider(address _providerAddress, string _name, bytes32 _application) {
    require(_providerAddress != address(0));
    // require(providers[_providerAddress] == 0);
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
      providers[_providerAddress].expires = _expires;
      providers[_providerAddress].approved = true;
      NewProvider(_providerAddress, providers[_providerAddress].name, providers[_providerAddress].application, true);
    } else {
      delete providers[_providerAddress];
    }
  }

}
