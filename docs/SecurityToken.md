# Security Token Protocol

This document describes the protocol for Polymath security tokens.
Security Tokens use Polymath compliance templates to ensure regulatory compliance
in the jurisdictions they are being offered in. The security token protocol is used
to ensure security tokens remain interoperable and fully open source so anyone can
build on top of the Polymath platform.

## Issuers workflow

### SecurityTokenRegistrar.sol flow

1. Polymath Launches the SecurityTokenRegistrar smart contract to Ethereum, now anyone can register a Security Token
2. Issuer purchases POLY utility tokens from PolyToken smart contract
3. Issuer approves transfer of 10000 POLY to SecurityTokenRegistrar contract
4. Issuer calls createSecurityToken() to create and register a new SecurityToken (Poly is transferedFrom Issuer's POLY balance)

### SecurityToken.sol flow

1. Token exists on the network after creation from SecurityTokenRegistrar.sol
2. The issuer sets the KYC provider they wish to use for the issuance
3. Attestors must approve a transfer of 10,000 POLY
3. Attestors must be added to the customers contract.
3. Legal delegates must be added as customers
4. Legal delegates make bids on the issuance
5. The issuer must approve the security contract to transfer the fee of the bid into the security
6. The issuer reviews all bids and calls setDelegate() with the Ethereum address of the legal delegate they wish to work with on the issuance
7. The issuer/delegate begin completing the compliance process (using the open sourced template) and calls updateComplianceProof() when steps are completed
8. Developers are also notified of the creation, review details and create STO contracts that meet the compliance specifications
9. The STO contract must be added to the registrar.
10. The STO fee must be approved for transfer by the ST contract.
9. Upon final approval, the legal delegate can use setSTOContract() to specify the SecurityTokenOffering contract address that will be used for the initial offering
10. STO contract address can be changed as long as the new/old start time > now and no tokens have been sent to the contract address (balances[STO] == 0) (this is not implemented really)

## Delegates workflow

### Compliance.sol flow

1. A delegate calls newDelegate() with their details to become a new Polymath delegate
2. Delegates can call createTemplate() to create new ST compliance templates
4. Delegates can now re-use templates for issuances and earn royalties if it becomes widely adopted by issuers

## KYC Providers workflow

1. A KYC provider calls newProvider() with their details to become a new Polymath KYC provider
2. Note: KYC Providers must pay N POLY tokens to get added as a KYC Provider
3. Approved KYC providers can now verifyInvestor()'s and earn tokens (the fee they specified) for doing so

## Investors (and issuers/delegates) workflow

### Customers.sol flow

1. Investors call newCustomer() with their documentation to become a new Polymath investor
2. The KYC provider specified by the investor reviews the documents and verifies the investor if requirements are met
3. The investor can now participate in certain SecurityTokenOfferings based on their jurisdiction/accreditation status
4. Issuers and delegates may also verify their addresses
