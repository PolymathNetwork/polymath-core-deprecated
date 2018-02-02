PIP: 1
  Title: PIP Purpose and Guidelines
  Status: Active
  Type: Core
  Author: Pablo Ruiz <pablo@polymath.network>, Satyam Agrawal <Satyam@polymath.network>
  Created: 2018-02-02

What is a PIP?
--------------

PIP stands for Polymath Improvement Proposal. A PIP is a design document providing information to the Polymath community, or describing a new feature for Polymath or its processes or environment or Security Token Proposals. The PIP should provide a concise technical specification of the feature and a rationale for the feature. The PIP author is responsible for building consensus within the community and documenting dissenting opinions.

PIP Rational
------------

We intend PIPs to be the primary mechanisms for proposing new features and new Security Token Proposals, for collecting community input on an issue, and for documenting the design decisions that have gone into Polymath. Because the PIPs are maintained as text files in a versioned repository, their revision history is the historical record of the feature proposal.

For Polymath implementers, PIPs are a convenient way to track the progress of their implementation. Ideally each implementation maintainer would list the PIPs that they have implemented. This will give end users a convenient way to know the current status of a given implementation or library.

PIP Categories
---------

There are two categories of PIP:

-   A **Core PIP** describes any change that affects most or all Polymath implementations, such as a change to the Core Polymath smart contracts, proposed application standards/conventions, or any change or addition that affects the interoperability of smart contracts using the Polymath standard.

-   **STO PIP** application-level standards and conventions around the development of Security Token Offerings (STOs) that implement the underlying Core smart contracts from Polymath.

PIP Work Flow
-------------

The PIP repository Collaborators change the PIPs status. Please send all PIP-related email to the PIP Collaborators, which is listed under PIP Editors below. Also see PIP Editor Responsibilities & Workflow.

The PIP process begins with a new idea for Polymath. It is highly recommended that a single PIP contain a single key proposal or new idea. The more focused the PIP, the more successful it tends to be. A change that affects or defines a standard for multiple apps to use requires a PIP. The PIP editor reserves the right to reject PIP proposals if they appear too unfocused or too broad. If in doubt, split your PIP into several well-focused ones.
For instance: Proposing a new STO that deals with Securities that pay dividends would require both a PIP for the STO and a Core PIP for changing the underlying mechanisms of the SecurityToken smart contract.

Each PIP must have a champion - someone who writes the PIP using the style and format described below, shepherds the discussions in the appropriate forums, and attempts to build community consensus around the idea.

Vetting an idea publicly before going as far as writing an PIP is meant to save the potential author time. Asking the Polymath community first if an idea is original helps prevent too much time being spent on something that is guaranteed to be rejected based on prior discussions (searching the Internet does not always do the trick). It also helps to make sure the idea is applicable to the entire community and not just the author. Just because an idea sounds good to the author does not mean it will work for most people in most areas where Polymath is used. Examples of appropriate public forums to gauge interest around your PIP include [the Issues section of this repository], and [one of the Polymath Gitter chat rooms]. In particular, [the Issues section of this repository] is an excellent place to discuss your proposal with the community and start creating more formalized language around your PIP.

Once the champion has asked the Polymath community whether an idea has any chance of acceptance a draft PIP should be presented as a [pull request]. This gives the author a chance to continuously edit the draft PIP for proper formatting and quality. This also allows for further public comment and the author of the PIP to address concerns about the proposal.

If the PIP collaborators approve, the PIP editor will assign the PIP a number (generally the issue or PR number related to the PIP), give it status “Draft”, and add it to the git repository. The PIP editor will not unreasonably deny a PIP. Reasons for denying PIP status include duplication of effort, being technically unsound, not providing proper motivation or addressing backwards compatibility, or not in keeping with the Polymath philosophy.

PIPs consist of three parts, a design document, implementation, and finally if warranted an update to the [formal specification]. The PIP should be reviewed and accepted before an implementation is begun, unless an implementation will aid people in studying the PIP.

For a PIP to be accepted it must meet certain minimum criteria. It must be a clear and complete description of the proposed enhancement. The enhancement must represent a net improvement. The proposed implementation, if applicable, must be solid and must not complicate the protocol unduly.

Once a PIP has been accepted, the implementations must be completed. When the implementation is complete and accepted by the community, the status will be changed to “Final”.

A PIP can also be assigned status “Deferred”. The PIP author or editor can assign the PIP this status when no progress is being made on the PIP. Once a PIP is deferred, the PIP editor can re-assign it to draft status.

An PIP can also be “Rejected”. Perhaps after all is said and done it was not a good idea. It is still important to have a record of this fact.

PIPs can also be superseded by a different PIP, rendering the original obsolete.

Some Informational and Process PIPs may also have a status of “Active” if they are never meant to be completed. E.g. PIP 1 (this PIP).

What belongs in a successful PIP?
---------------------------------

Each PIP parts are explained in pip-X.md template file.

Transferring PIP Ownership
--------------------------

It occasionally becomes necessary to transfer ownership of PIPs to a new champion. In general, we'd like to retain the original author as a co-author of the transferred PIP, but that's really up to the original author. A good reason to transfer ownership is because the original author no longer has the time or interest in updating it or following through with the PIP process, or has fallen off the face of the 'net (i.e. is unreachable or not responding to email). A bad reason to transfer ownership is because you don't agree with the direction of the PIP. We try to build consensus around a PIP, but if that's not possible, you can always submit a competing PIP.

If you are interested in assuming ownership of a PIP, send a message asking to take over, addressed to both the original author and the PIP editor. If the original author doesn't respond to email in a timely manner, the PIP editor will make a unilateral decision (it's not like such decisions can't be reversed :).

PIP Editors
-----------

The current PIP editors are

` * Satyam Agrawal (@satyamakgec)`

` * Pablo Ruiz (@pabloruiz55)`

PIP Editor Responsibilities and Workflow
--------------------------------------

For each new PIP that comes in, an editor does the following:

-   Read the PIP to check if it is ready: sound and complete. The ideas must make technical sense, even if they don't seem likely to be accepted.
-   The title should accurately describe the content.
-   Edit the PIP for language (spelling, grammar, sentence structure, etc.), markup (Github flavored Markdown), code style

If the PIP isn't ready, the editor will send it back to the author for revision, with specific instructions.

Once the PIP is ready for the repository, the PIP editor will:

-   Assign an PIP number (generally the PR number or, if preferred by the author, the Issue # if there was discussion in the Issues section of this repository about this PIP)

<!-- -->

-   Accept the corresponding pull request

<!-- -->

-   List the PIP in [README.md]

<!-- -->

-   Send a message back to the PIP author with next step.

Many PIPs are written and maintained by developers with write access to the Polymath codebase. The PIP editors monitor PIP changes, and correct any structure, grammar, spelling, or markup mistakes we see.

The editors don't pass judgment on PIPs. We merely do the administrative & editorial part.

History
-------

This document was derived heavily from [Ethereum's EIP-1] which in turn was derived heavily from [Bitcoin's BIP-0001] written by Amir Taaki which in turn was derived from [Python's PEP-0001]. In many places text was simply copied and modified. 

Copyright
---------

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
