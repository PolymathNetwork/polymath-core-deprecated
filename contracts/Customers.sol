pragma solidity ^0.4.18;

import './PolyToken.sol';

/*
Polymath customer registry is used to ensure regulatory compliance
of the investors, provider, and issuers. The customers registry is a central
place where ethereum addresses can be whitelisted to purchase certain security
tokens based on their verifications by providers.
*/

contract Customers {

    PolyToken POLY;

    // A Customer
    struct Customer {
        bytes32 jurisdiction;
        uint256 joined;
        uint8 role;
        bool verified;
        bool accredited;
        bool flagged;
        bytes32 proof;
        uint256 expires;
    }

    // Customers
    mapping (address => mapping (address => Customer)) public customers;

    // KYC/Accreditation Provider
    struct Provider {
        string name;
        uint256 joined;
        bytes32 details;
        uint256 fee;
    }

    // KYC/Accreditation Providers
    mapping(address => Provider) public providers;

    // Notifications
    event NewProvider(address providerAddress, string name, bytes32 details);
    event NewCustomer(address customer, address provider, bytes32 jurisdiction, uint8 role, bytes32 proof, bool verified);

    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    // Constructor
    function Customers(address _polyTokenAddress) public {
        POLY = PolyToken(_polyTokenAddress);
    }

    /// Allow new provider applications
    /// @param _providerAddress The provider's public key address
    /// @param _name The provider's name
    /// @param _details A SHA256 hash of the new providers details
    /// @param _fee The fee charged for customer verification
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public {
        require(_providerAddress != address(0));
        require(providers[_providerAddress].details != 0);
        // Require 10,000 POLY fee
        POLY.transferFrom(_providerAddress, this, 10000);
        providers[_providerAddress].name = _name;
        providers[_providerAddress].details = _details;
        providers[_providerAddress].fee = _fee;
        providers[_providerAddress].joined = now;
        NewProvider(_providerAddress, _name, _details);
    }

    /// Allow new investor applications
    /// @param _jurisdiction The jurisdiction code of the customer
    /// @param _provider The provider selected by the customer
    ///  to do verification
    /// @param _role The type of customer - investor:1, issuer:2, delegate:3
    /// @param _proof The SHA256 hash of the documentation provided
    ///  to prove identity
    function newCustomer(bytes32 _jurisdiction, address _provider, uint8 _role, bytes32 _proof) public {
        customers[_provider][msg.sender].jurisdiction = _jurisdiction;
        customers[_provider][msg.sender].role = _role;
        customers[_provider][msg.sender].verified = false;
        customers[_provider][msg.sender].accredited = false;
        customers[_provider][msg.sender].flagged = false;
        customers[_provider][msg.sender].proof = _proof;
        customers[_provider][msg.sender].joined = now;
        NewCustomer(msg.sender, _provider, _jurisdiction, _role, _proof, false);
    }

    /// Verify an investor
    /// @param _customer The customer's public key address
    /// @param _jurisdiction The jurisdiction code of the customer
    /// @param _role The type of customer - investor:1, issuer:2, delegate:3, marketmaker:4,
    /// @param _accredited Whether the customer is accredited or
    ///  not (only applied to investors)
    /// @param _proof The SHA256 hash of the documentation provided
    ///  to prove identity
    /// @param _expires The time the verification expires
    function verifyCustomer(
        address _customer,
        bytes32 _jurisdiction,
        uint8 _role,
        bool _accredited,
        bytes32 _proof,
        uint256 _expires
    ) public onlyProvider
    {
        require(customers[msg.sender][_customer].verified == false);
        require(customers[msg.sender][_customer].role != 0);
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].jurisdiction = _jurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        customers[msg.sender][_customer].verified = true;
        NewCustomer(
            _customer,
            msg.sender,
            _jurisdiction,
            _role,
            _proof,
            true
        );
    }

    /// Getter function for attestations
    function getCustomer(address _provider, address _customer) public constant returns (
      bytes32,
      bool,
      uint8,
      bool,
      uint256
    ) {
        return (
          customers[_provider][_customer].jurisdiction,
          customers[_provider][_customer].accredited,
          customers[_provider][_customer].role,
          customers[_provider][_customer].verified,
          customers[_provider][_customer].expires
        );
    }

}
