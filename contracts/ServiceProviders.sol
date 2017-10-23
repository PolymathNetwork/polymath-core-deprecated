pragma solidity ^0.4.15;

import './Ownable.sol';


/*
Polymath compliance templates protocol is used to ensure regulatory compliance
in the jurisdictions that security tokens are being offered in. The compliance
protocol ensures security tokens remain interoperable so that anyone can
build on top of the Polymath platform and extend it's functionality.
*/

contract ServiceProviders is Ownable {

  // Service provider details
  struct Provider {
    bytes32 service;
    bytes32 application;
    uint256 fee;
    bool approved;
  }

  // Service provider registry
  mapping(address => Provider) public serviceProviders;

  // Notifications
  event ServiceProviderApplication(address _serviceProviderAddress, bytes32 _service);
  event ServiceProviderApproved(address _serviceProviderAddress);

  /// Allow new service provider applications
  /// @param _serviceProviderAddress The service provider's public key address
  /// @param _application A SHA256 hash of the application document
  /// @param _service The type of services provided
  /// @param _fee The fee charged for the services provided in POLY
  function newServiceProvider(address _serviceProviderAddress, bytes32 _application, bytes32 _service, uint256 _fee) {
    require(_serviceProviderAddress != address(0));
    serviceProviders[_serviceProviderAddress] = Provider(_service, _application, _fee, false);
    ServiceProviderApplication(_serviceProviderAddress, _service);
  }

  /// Approve or reject a service provider application
  /// @param _serviceProviderAddress The legal delegate's public key address
  /// @param _approved Whether the service provider was approved or not
  /// @param _service The service that has been approved for
  /// @param _expires Timestamp the service provider is valid on Polymath until
  function approveServiceProvider(address _serviceProviderAddress, bool _approved, bytes32 _service, uint256 _expires) onlyOwner {
    require(serviceProviders[_serviceProviderAddress].service != 0x0);
    require(_expires >= now);
    if (_approved == true) {
      serviceProviders[_serviceProviderAddress].approved = true;
      serviceProviders[_serviceProviderAddress].service = _service;
      ServiceProviderApproved(_serviceProviderAddress);
    } else {
      serviceProviders[_serviceProviderAddress].approved = false;
      serviceProviders[_serviceProviderAddress].service = 0x0;
    }
  }
}
