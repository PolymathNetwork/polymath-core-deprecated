pragma solidity ^0.4.18;

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by providers.
*/

import './interfaces/IERC20.sol';
import './interfaces/ICustomers.sol';

/**
 * @title Customers
 * @dev Contract use to register the user on the Platform platform
 */

contract Customers is ICustomers {

    string public VERSION = "1";

    IERC20 POLY;                                                        // Instance of the POLY token

    struct Customer {                                                   // Structure use to store the details of the customers
        bytes32 countryJurisdiction;                                    // Customers country jurisdiction as ex - ISO3166
        bytes32 divisionJurisdiction;                                   // Customers sub-division jurisdiction as ex - ISO3166
        uint256 joined;                                                 // Timestamp when customer register
        uint8 role;                                                     // role of the customer
        bool accredited;                                                // Accrediation status of the customer
        bytes32 proof;                                                  // Proof for customer
        uint256 expires;                                                // Timestamp when customer verification expires
    }

    mapping(address => mapping(address => Customer)) public customers;  // Customers (kyc provider address => customer address)
    mapping(address => mapping(uint256 => bool)) public nonceMap;       // Map of used nonces by customer

    struct Provider {                                                   // KYC/Accreditation Provider
        string name;                                                    // Name of the provider
        uint256 joined;                                                 // Timestamp when provider register
        bytes32 details;                                                // Details of provider
        uint256 fee;                                                    // Fee charged by the KYC providers
    }

    mapping(address => Provider) public providers;                      // KYC/Accreditation Providers

    // Notifications
    event LogNewProvider(address indexed providerAddress, string name, bytes32 details);
    event LogCustomerVerified(address indexed customer, address indexed provider, uint8 role);

    // Modifier
    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    /**
     * @dev Constructor
     */
    function Customers(address _polyTokenAddress) public {
        POLY = IERC20(_polyTokenAddress);
    }

    /**
     * @dev Allow new provider applications
     * @param _providerAddress The provider's public key address
     * @param _name The provider's name
     * @param _details A SHA256 hash of the new providers details
     * @param _fee The fee charged for customer verification
     */
    function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
        require(_providerAddress != address(0));
        require(_details != 0x0);
        require(providers[_providerAddress].details == 0x0);
        providers[_providerAddress] = Provider(_name, now, _details, _fee);
        LogNewProvider(_providerAddress, _name, _details);
        return true;
    }

    /**
     * @dev Change a providers fee
     * @param _newFee The new fee of the provider
     */
    function changeFee(uint256 _newFee) onlyProvider public returns (bool success) {
        providers[msg.sender].fee = _newFee;
        return true;
    }


    /**
     * @dev Verify an investor
     * @param _customer The customer's public key address
     * @param _countryJurisdiction The jurisdiction country code of the customer
     * @param _divisionJurisdiction The jurisdiction subdivision code of the customer
     * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
     * @param _accredited Whether the customer is accredited or not (only applied to investors)
     * @param _expires The time the verification expires
     * @param _nonce nonce of signature (avoid replay attack)
     * @param _v customer signature
     * @param _r customer signature
     * @param _s customer signature
     */
    function verifyCustomer(
        address _customer,
        bytes32 _countryJurisdiction,
        bytes32 _divisionJurisdiction,
        uint8 _role,
        bool _accredited,
        uint256 _expires,
        uint _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public onlyProvider returns (bool success)
    {
        require(_expires > now);
        require(nonceMap[_customer][_nonce] == false);
        nonceMap[_customer][_nonce] = true;
        bytes32 hash = keccak256(this, msg.sender, _countryJurisdiction, _divisionJurisdiction, _role, _accredited, _nonce);
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), _v, _r, _s) == _customer);
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].countryJurisdiction = _countryJurisdiction;
        customers[msg.sender][_customer].divisionJurisdiction = _divisionJurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        LogCustomerVerified(_customer, msg.sender, _role);
        return true;
    }

    ///////////////////
    /// GET Functions
    //////////////////

    /**
     * @dev Get customer attestation data by KYC provider and customer ethereum address
     * @param _provider Address of the KYC provider.
     * @param _customer Address of the customer ethereum address
     */
    function getCustomer(address _provider, address _customer) public view returns (
        bytes32,
        bytes32,
        bool,
        uint8,
        uint256
    ) {
      return (
        customers[_provider][_customer].countryJurisdiction,
        customers[_provider][_customer].divisionJurisdiction,
        customers[_provider][_customer].accredited,
        customers[_provider][_customer].role,
        customers[_provider][_customer].expires
      );
    }

    /**
     * Get provider details and fee by ethereum address
     * @param _providerAddress Address of the KYC provider
     */
    function getProvider(address _providerAddress) public view returns (
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
