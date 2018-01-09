# Polymath Investors

Polymath investors provide capital to Security Token issuers on the Polymath
network. This is done by contributing POLY or ETH to Security Token Offering
contracts, or through secondary markets (exchanges, over the counter, etc.).

## Why invest in Polymath Security Tokens?

Security tokens allow you to invest in real world assets, i.e. equities, debt,
derivatives, etc. Unlike utility tokens, which are only used to gain access to a
decentralized platform or protocol, security tokens can be issued and purchased
explicitly for investment purposes.

## How do I invest in Security Tokens on Polymath?

1. In order to invest a security tokens, you will need to meet the requirements
   the security token regulations you wish to invest in. So the first step is to
   find the security token offering you are interested in. With the contract
   address you can obtain the regulatory template details via the
   `SecurityToken.getTokenDetails()` function.

2. Using the template address, you can now call
   `Template.checkTemplateRequirements()` with your jurisdiction and
   accreditation status to determine if you are be eligible to invest in the
   security token.

3. If you are eligible to own the security token, you should begin the KYC
   process by going to the KYC provider onboarding page and uploading the
   required identity and accreditation documents. The KYC provider address was
   provided in step 2, and additional details can be obtained via the
   `Customers.getProvider()` function.

4. After the KYC provider has verified your identity and accreditation status,
   your ethereum address will be added to the security token whitelist. Allowing
   you to participate in both the initial Security Token Offering (STO), or
   trade the token to other verified investors through secondary markets.

For example, if you are investing in Alice Inc. security tokens which are issued
out of the USA as a 506 (b) offering and specifies a KYC provider as Bob KYC
Inc. (which checks accreditation status), you as an investor will need to visit
bobskyc.com and upload your proof of identity/accreditation status. If
successful, bobskyc.com will add you to the Security token whitelist, and you
will be able to participate in the Security Token offering or purchase it on
secondary markets.
