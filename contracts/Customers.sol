pragma solidity ^0.4.18;

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by providers.
*/

import './PolyToken.sol';
import './interfaces/ICustomers.sol';

contract Customers is ICustomers {

    PolyToken POLY;

    uint256 public constant newProviderFee = 1000;

    // A Customer
    struct Customer {
        bytes32 jurisdiction;
        uint256 joined;
        uint8 role;
        bool verified;
        bool accredited;
        bytes32 proof;
        uint256 expires;
    }

    // Customers (kyc provider address => customer address)
    mapping(address => mapping(address => Customer)) public customers;

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
    event LogNewProvider(address providerAddress, string name, bytes32 details);
    event LogCustomerVerified(address customer, address provider, uint8 role);

    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    // Constructor
    function Customers(address _polyTokenAddress) public {
        POLY = PolyToken(_polyTokenAddress);
    }

    /* @dev Allow new provider applications
    @param _providerAddress The provider's public key address
    @param _name The provider's name
    @param _details A SHA256 hash of the new providers details
    @param _fee The fee charged for customer verification */
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
        require(_providerAddress != address(0));
        require(_details != 0x0);
        require(providers[_providerAddress].details == 0);
        require(POLY.transferFrom(_providerAddress, address(this), newProviderFee));
        providers[_providerAddress] = Provider(_name, now, _details, _fee);
        LogNewProvider(_providerAddress, _name, _details);
        return true;
    }

    /* @dev Change a providers fee
    @param _newFee The new fee of the provider */
    function changeFee(uint256 _newFee) public returns (bool success) {
        require(providers[msg.sender].details != 0);
        providers[msg.sender].fee = _newFee;
        return true;
    }

    /* @dev Verify an investor
    @param _customer The customer's public key address
    @param _jurisdiction The jurisdiction code of the customer
    @param _role The type of customer - investor:1, issuer:2, delegate:3, marketmaker:4, etc.
    @param _accredited Whether the customer is accredited or not (only applied to investors)
    @param _expires The time the verification expires */
    function verifyCustomer(
        address _customer,
        bytes32 _jurisdiction,
        uint8 _role,
        bool _accredited,
        uint256 _expires
    ) public onlyProvider returns (bool success)
    {
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].jurisdiction = _jurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        customers[msg.sender][_customer].verified = true;
        LogCustomerVerified(_customer, msg.sender, _role);
        return true;
    }

    // Get customer attestation data by KYC provider and customer ethereum address
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

    // Get provider details and fee by ethereum address
    function getProvider(address _providerAddress) public constant returns (
        string name,
        uint256 joined,
        bytes32 details,
        uint256 fee
    ) {
      return (
        providers[_providerAddress].name,
        providers[_providerAddress].joined,
        providers[_providerAddress].details,
        providers[_providerAddress].fee
      );
    }

}
