# Polymath Issuers

Polymath issuers raise funds through Polymath via Security Token Offerings. They
do this by tokenizing their assets, i.e. company/hedge fund/trust equity, or
debt instruments.

## How do I issue a security token?

1. In order to issue a security token, you should first visit a security token
   creation wizard which helps match issuers with delegates and developers to
   create a fully compliant security token offering.

2. Once you find a security token creation host, you will enter the details of
   your offering. The required details are token name, total supply, ticker
   name, percent raised in POLY, issuing jurisdiction, your ethereum address,
   and potentially many other fields (depending on what the host deems
   necessary). Only the fields mentioned above are required to create the
   security token on-chain.

3. Depending on the host, you may be required to pre-authorize a payment in
   POLY, for the services offered by the host. This can be done via the
   `PolyToken.approve()` function.

4. The host will review details, and will call
   `SecurityTokenRegistrar.createSecurityToken()` with the details of the
   Security Token. Note: if a fee is required by the host and the
   pre-authorization was not made by the issuer in step 3, this transaction will
   fail.

5. The host will provide you with the result of the creation and forward the
   issuance details along to the delegate and developer network to begin
   making proposals for the issuance. The security tokens are created and
   transferred to the Ethereum address provided in step 2. At this stage, the
   tokens will be non-transferrable.

6. Delegates will make proposals of different compliance templates that can be
   applied to the security token. These can be listened to via the
   `Compliance.LogNewTemplateProposal` event. Developer proposals can be done
   similarly through `Compliance.LogNewDeveloperProposal`.

7. After reviewing proposals, the issuer can select a template proposal via the
   `SecurityToken.selectTemplate()` function and a developer proposal via the
   `SecurityToken.selectOfferingProposal()` function. At this point investors
   are now eligible to begin the KYC process (specified by the template) and the
   issuer is eligible to transfer the Security Token to the STO contract
   (specified by the offering proposal).

8. Once the offering start time begins, the raised funds will begin transferring
   to the issuers address (in accordance with the STO contract spec).
