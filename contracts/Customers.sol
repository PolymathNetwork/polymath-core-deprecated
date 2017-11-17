pragma solidity ^0.4.15;

import './Ownable.sol';
import './PolyToken.sol';

/*
Polymath customer registry is used to ensure regulatory compliance
of the investors, attestor, and issuers. The customers registry is a central
place where ethereum addresses can be whitelisted to purchase certain security
tokens based on their verifications by attestors.
*/

contract Customers is Ownable {

    PolyToken POLY;

    // A Customer
    struct Customer {
        bytes32 jurisdiction;
        uint8 role;
        bool verified;
        bool accredited;
        bool flagged;
        bytes32 proof;
        uint256 expires;
    }

    // Customers
    mapping (address => mapping (address => Customer)) customers;

    // Attestation Attestor
    struct Attestor {
        string name;
        bytes32 details;
        uint256 fee;
    }

    // Attestation Attestors
    mapping(address => Attestor) public attestors;

    // Notifications
    event NewAttestor(address attestorAddress, string name, bytes32 details);
    event NewCustomer(address customer, address attestor, bytes32 jurisdiction, uint8 role, bytes32 proof, bool verified);

    modifier onlyAttestor() {
        require(attestors[msg.sender].details != 0x0);
        _;
    }

    // Constructor
    function Customers(address _polyTokenAddress) public {
        POLY = PolyToken(_polyTokenAddress);
    }

    /// Allow new attestor applications
    /// @param _attestorAddress The attestor's public key address
    /// @param _name The attestor's name
    /// @param _details A SHA256 hash of the new attestors details
    /// @param _fee The fee charged for customer verification
    function newAttestor(address _attestorAddress, string _name, bytes32 _details, uint256 _fee) public {
        require(_attestorAddress != address(0));
        require(attestors[_attestorAddress].details != 0);
        // Require 10,000 POLY fee
        POLY.transferFrom(_attestorAddress, this, 10000);
        attestors[_attestorAddress].name = _name;
        attestors[_attestorAddress].details = _details;
        attestors[_attestorAddress].fee = _fee;
        NewAttestor(_attestorAddress, _name, _details);
    }

    /// Allow new investor applications
    /// @param _jurisdiction The jurisdiction code of the customer
    /// @param _attestor The attestor selected by the customer
    ///  to do verification
    /// @param _role The type of customer - investor:1, issuer:2, delegate:3
    /// @param _proof The SHA256 hash of the documentation provided
    ///  to prove identity
    function newCustomer(bytes32 _jurisdiction, address _attestor, uint8 _role, bytes32 _proof) public {
        customers[_attestor][msg.sender].jurisdiction = _jurisdiction;
        customers[_attestor][msg.sender].role = _role;
        customers[_attestor][msg.sender].verified = false;
        customers[_attestor][msg.sender].accredited = false;
        customers[_attestor][msg.sender].flagged = false;
        customers[_attestor][msg.sender].proof = _proof;
        NewCustomer(msg.sender, _attestor, _jurisdiction, _role, _proof, false);
    }

    /// Verify an investor
    /// @param _customer The customer's public key address
    /// @param _jurisdiction The jurisdiction code of the customer
    /// @param _role The type of customer - investor:1 or issuer:2
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
    ) public onlyAttestor
    {
        require(customers[msg.sender][_customer].verified == false);
        require(customers[msg.sender][_customer].role != 0);
        POLY.transferFrom(_customer, msg.sender, attestors[msg.sender].fee);
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
    function getCustomer(address _attestor, address _customer) public returns (
      bytes32 jurisdiction,
      bool accredited,
      uint8 role,
      bool verified,
      uint256 expires
    ) {
        Customer memory customer = customers[_attestor][_customer];
        require(customer.verified);
        return (customer.jurisdiction, customer.accredited, customer.role, customer.verified, customer.expires);
    }

}
