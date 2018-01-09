# Polymath ST20 Templates

In order to streamline the process of issuing a compliant security token, and
leveraging the decentralized and open nature of blockchains, the concept of a
security token compliance template is used.

Compliance templates allow issuers to easily apply transfer restrictions and a
KYC provider to ST20 tokens. The main function of templates are to specify the
jurisdictions and accreditation status that the investor must be set to (by a
the KYC provider on the template) to hold the security token. If they do not
meet the template requirements, any transfer of security tokens to their address
will fail. They can also store a hash of documents related to the offering
requirements on chain.

## Who creates templates?

Delegates will create templates, and it is likely that the community will steer
towards a few templates based off recommendations by industry leaders. It is
also possible that individual hosts create their own templates that fit within
their existing processes.

## What is in a template?

owner - The delegate who is claiming the template meets regulatory requirements
by creating the template

offeringType - A string description i.e. 506b

issuerJurisdiction - The issuers ISO3166 jurisdiction

allowedJurisdiction - A mapping of allowed ISO3166 jurisdictions

allowedRoles - A mapping of allowed roles (uint)

accredited - Whether or not the investor must be accredited

KYC - The KYC providers address

details - A hash of compliance documents for the security offering

finalized - Allows the owner to make edits to the template and finalize it when
ready

expires - When the template expires and can no longer be applied to security
tokens

fee - The fee the delegate would like for their services

quorum - The percent of initial investors in the security token to freeze
service fee

vestingPeriod - How long the delegate is willing to lockup their service fees
