# Polymath KYC Providers

Polymath issuers raise funds through Polymath via Security Token offerings. They
do this by tokenizing their assets, i.e. company/hedge fund/trust equity, or
debt instruments.

## How do I verify an investor?

1. Become a KYC provider by calling `Compliance.newProvider()` and pay the
   required fee to join as a KYC provider (to prevent spam). A KYC provider can
   create multiple providers to represent different types of verification
   'packages' for different fees.

2. Investor uploads docs to your API with an Ethereum address.

3. You run KYC verification, accreditation checks or whatever the attestation
   requirements of your package offers and make a call to the
   `Customers.verifyCustomer()` function.
