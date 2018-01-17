pragma solidity ^0.4.18;

/*
  Polymath customer registry is used to ensure regulatory compliance
  of the investors, provider, and issuers. The customers registry is a central
  place where ethereum addresses can be whitelisted to purchase certain security
  tokens based on their verifications by providers.
*/

import './PolyToken.sol';
import './interfaces/ICustomers.sol';
import './Ownable.sol';

/**
 * @title Customers
 * @dev Contract use to register the user on the Platform platform
 */

contract Customers is ICustomers, Ownable {

    string public VERSION = "1";

    PolyToken POLY;                                                     // Instance of the POLY token

    uint256 public NEW_PROVIDER_FEE = 1000;                             // Constant variable which holds the fee to register the KYC Oracles

    struct Customer {                                                   // Structure use to store the details of the customers
        bytes32 jurisdiction;                                           // Customers jurisdiction as ex - ISO3166 
        uint256 joined;                                                 // Timestamp when customer register
        uint8 role;                                                     // role of the customer 
        bool verified;                                                  // Boolean variable to check the status of the customer whether it is verified or not 
        bool accredited;                                                // Accrediation status of the customer
        bytes32 proof;                                                  // Proof for customer
        uint256 expires;                                                // Timestamp when customer verification expires 
    }

    mapping(address => mapping(address => Customer)) public customers;  // Customers (kyc provider address => customer address)

    struct Provider {                                                   // KYC/Accreditation Provider
        string name;                                                    // Name of the provider 
        uint256 joined;                                                 // Timestamp when provider register     
        bytes32 details;                                                // Details of provider 
        uint256 fee;                                                    // Fee charged by the KYC providers
        bool active;                                                    // Whether the provider is active or not
    }

    mapping(address => Provider) public providers;                      // KYC/Accreditation Providers

    // Notifications
    event LogNewProvider(address providerAddress, string name, bytes32 details);
    event LogCustomerVerified(address customer, address provider, uint8 role);
    
    // Modifier
    modifier onlyProvider() {
        require(providers[msg.sender].details != 0x0);
        _;
    }

    /**
     * @dev Constructor 
     */
    function Customers(address _polyTokenAddress) public {
        owner = msg.sender;
        POLY = PolyToken(_polyTokenAddress);
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
        require(POLY.transferFrom(_providerAddress, address(this), NEW_PROVIDER_FEE));
        providers[_providerAddress] = Provider(_name, now, _details, _fee, false);
        LogNewProvider(_providerAddress, _name, _details);
        return true;
    }

    /**
     * @dev Change a providers fee
     * @param _newFee The new fee of the provider 
     */
    function changeFee(uint256 _newFee) public returns (bool success) {
        require(providers[msg.sender].details != 0x0);
        providers[msg.sender].fee = _newFee;
        return true;
    }

    /** 
     * @dev Verify an investor
     * @param _customer The customer's public key address
     * @param _jurisdiction The jurisdiction code of the customer
     * @param _role The type of customer - investor:1, delegate:2, issuer:3, marketmaker:4, etc.
     * @param _accredited Whether the customer is accredited or not (only applied to investors)
     * @param _expires The time the verification expires 
     */
    function verifyCustomer(
        address _customer,
        bytes32 _jurisdiction,
        uint8 _role,
        bool _accredited,
        uint256 _expires
    ) public onlyProvider returns (bool success)
    {   
        require(_expires > now);
        require(providers[msg.sender].active);
        require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
        customers[msg.sender][_customer].jurisdiction = _jurisdiction;
        customers[msg.sender][_customer].role = _role;
        customers[msg.sender][_customer].accredited = _accredited;
        customers[msg.sender][_customer].expires = _expires;
        customers[msg.sender][_customer].verified = true;
        LogCustomerVerified(_customer, msg.sender, _role);
        return true;
    }

    //////////////////////////
    ///// Owner functions
    //////////////////////////

    /**
     * @dev Used to withdraw POLY from the contract to owner account
     * @return bool
     */
    function withdrawReservePoly(address _to) onlyOwner public returns(bool) {
        uint256 balance = POLY.balanceOf(this);
        require(POLY.transfer(_to,balance));
        return true;
    }

    /**
     * @dev Use to change the Registeration fee for Providers to register on platform
     * @param _newProviderFee New Fee charged to providers
    
     */

    function changeRegisterationFee(uint256 _newProviderFee) onlyOwner public {
        require(_newProviderFee > 0);
        NEW_PROVIDER_FEE = _newProviderFee;
    }

    /**
     * @dev Owner change the flag active to true or false
     * @param _providersList List of addresses of providers
     * @param _status List of value of active flag
     */

    function changeStatus(address[] _providersList, bool[] _status) onlyOwner public {
        require(_providersList.length == _status.length);
        for (uint256 i = 0; i < _providersList.length; i++ ) {
            providers[_providersList[i]].active = _status[i];
        }
    }

    ///////////////////
    /// GET Functions
    //////////////////

    /**
     * @dev Get customer attestation data by KYC provider and customer ethereum address
     * @param _provider Address of the KYC provider.
     * @param _customer Address of the customer ethereum address
     */
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

    /**
     * Get provider details and fee by ethereum address
     * @param _providerAddress Address of the KYC provider
     */
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
