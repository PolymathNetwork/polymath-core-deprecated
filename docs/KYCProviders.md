# Polymath KYC Providers

Polymath KYC providers attest customer claims such as identity, accreditation
status, customer type (investor, issuer, exchange, etc), and potentially other
information. A KYC provider could use manual methods, an 3rd party verification
API, or a mix of both.

KYC providers are an essential role in the Polymath ecosystem and gain
reputation extrinsically by being reused on different compliance templates.

## How do I verify an investor?

1. Become a KYC provider by calling `Compliance.newProvider()` and pay the
   required fee to join as a KYC provider (to prevent spam). A KYC provider can
   create multiple providers to represent different types of verification
   'packages' for different fees.

2. Investor uploads their identity documents to your API or manually with an
   Ethereum address.

3. You run KYC verification, accreditation checks or whatever the attestation
   requirements of your package offers and make a call to the
   `Customers.verifyCustomer()` function.

4. (This part can be done by anyone) The investor/issuer calls
   `SecurityToken.addToWhitelist()` which checks the KYC provider address
   customer datastore in Customers.sol and verifies the customer verifications
   meet the security token compliance template requirements.

For example, if the Government of Zimbabwe wants to issue a universal income
token which has voting rights to it's citizens. They could create a new KYC
provider address and require each citizen to visit their office with documents
and an ethereum address. Once verified, they would make the function call to add
them to their datastore in Customers.sol and call addToWhitelist in the Zimbabwe
Universal Income security token. Additionally, other issuers looking want to
issue security tokens to only Zimbawe citizens in the future, as long as the
investor verifications haven't expired (specified by the KYC provider when
adding them to the datastore), they can be added to the new security token
whitelist without having to re-verify.
