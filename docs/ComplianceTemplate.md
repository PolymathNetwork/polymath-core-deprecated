# Compliance Protocol

This document describes the protocol for Polymath compliance templates.
Security Tokens use Polymath compliance templates to ensure regulatory compliance
in the jurisdictions they are being offered in. The compliance protocol is used
to ensure security tokens remain interoperable and fully open source so anyone can
build on top of the Polymath platform.

## Becoming a legal delegate

Legal delegates are eligible to creater compliance templates on Polymath, anyone
can apply through the newDelegate function. The legal delegate must upload an application
with their CV either to Polymath platform or a service provider. The SHA256 hash of
the document will be linked to the delegate for audit/review purposes.


```
newDelegate (
  address _delegateAddress,
  bytes32 _application
)
```

\_delegateAddress - The Ethereum public key of the new legal delegate
\_application - SHA256 hash of the application document

## Approve legal delegate

Polymath Inc. will review the legal delegate's qualifications and request any followup
documentation if necessary. Based on the qualifications, the delegate will be approved
to review and bid on issuances in specific jurisdictions. This function is only accessible to
contract owners. In the future it will be transferred to a multi-sig wallet controlled by the
entire Polymath network.

```
approveDelegate (
  address _delegateAddress,
  uint8[] _jurisdictions
)
```

\_delegateAddress - The Ethereum public key of the delegate
\_jurisdictions - An array of valid jurisdiction id's.

## Create compliance template

Legal delegates can propose new compliance templates for Polymath Security Tokens by
specifying the jurisdiction the issuer is based, and the jurisdictions they would like
to offer the security to.

```
newTemplate (
  address _delegateAddress,
  string _template,
  uint4 _tasks,
  uint8 _issuerJurisdiction,
  uint8[] _restrictedJurisdictions,
  string type,
  uint256 _fee,
  uint256 _expires
)
```

\_delegateAddress - The Ethereum public key of the legal delegate who owns the template
\_template - A SHA256 hash of the compliance template document outlining the compliance process
\_tasks - The number of compliance tasks in the template
\_issuerJurisdictions - The jurisdiction id of the issuer
\_restrictedJurisdictions - An array of jurisdictions that are blocked from purchasing the security
\_type - A description of the compliance template type
\_fee - Amount of POLY to use the template (held in escrow until issuance)
\_expires - Timestamp the template expires

## Approve compliance template

A compliance template must be approved by the Polymath team, this is done using the approveTemplate function.
In the future this will be governed by the network.

```
approveTemplate (
  string _templateId,
  boolean _approved
)
```

\_templateId - The id of the compliance template being approved
\_approved - If true, the compliance template can be applied to ST's, otherwise it is deleted

## Add a Jurisdiction

A lookup table for jurisdiction ID's to name. Follows the [ISO 3166 standard](https://en.wikipedia.org/wiki/ISO_3166).

```
addJurisdiction (bytes8 _code)
```

\_code - The ISO 3166 code of the jurisdiction
