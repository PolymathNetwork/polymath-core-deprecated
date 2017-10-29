# Security Token Protocol

This document describes the protocol for Polymath security tokens.
Security Tokens use Polymath compliance templates to ensure regulatory compliance
in the jurisdictions they are being offered in. The security token protocol is used
to ensure security tokens remain interoperable and fully open source so anyone can
build on top of the Polymath platform.

## Issuers workflow

### SecurityTokens.sol flow

1. Polymath Launches the SecurityTokens smart contract to Ethereum, now users can create Security Tokens
2. A User of Polymath decides to launch an ST, and calls createSecurityToken(). It uses SecurityToken.sol to make one
3. See SecurityToken.sol workflow to see how a User who launched an ST would get legal and developer help on their token

### SecurityToken.sol flow

1. Token exists on the network after creation from SecurityTokens.sol
2. A legal delegate will be notified of creation, review details and calls proposeComplianceTemplate() with a template and bid for the offering
3. The issuer reviews all proposals and calls setDelegate() with the address of the proposal they wish to move forward with
4. Note: the issuer must have sent enough POLY to cover the bounty specified in the bid
5. The issuer begins the compliance process (using the open sourced templates) and calls updateComplianceProof() when process steps are completed
6. Upon final approval, the delegate can set setSTOAddress() to specify the SecurityTokenOffering contract that will be used for the initial offering
7. The issuer selects a KYC provider for the issuance using setKYC()

## Delegates workflow

### Compliance.sol flow

1. A delegate calls newDelegate() with their application to become a new Polymath delegate
2. Polymath network reviews the application and either approves or rejects the application
3. Approved delegates can call createTemplate() to create new ST compliance templates
4. Polymath network reviews the compliance template and either approves or rejects it
5. Delegates can now re-use templates for issuances and earn royalties if it becomes widely adopted by issuers

## KYC Providers workflow

1. A KYC provider calls newProvider() with their application to become a new Polymath KYC provider
2. Polymath network reviews the application and either approves or rejects the application
3. Approved KYC providers can now verifyInvestor()'s and earn tokens for doing so

## Investors (and issuers/delegates) workflow

### Customers.sol flow

1. Investors call newCustomer() with their documentation to become a new Polymath investor
2. The KYC provider specified by the investor reviews the documents and verifies the investor if requirements are met
3. The investor can now participate in certain SecurityTokenOfferings based on their jurisdiction/accreditation status
4. Issuers and delegates may also verify their addresses
