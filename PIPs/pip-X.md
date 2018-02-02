Suggested Template for new PIPs.   
Raised PIPs should not affect the current protocol version.  

### Guidelines
When opening a pull request to submit your PIP please use an abbreviated filename pip-draft_title_abbrev.md.   
PIP number will be assigned by an editor.   
The title should be 44 characters or less.   


## Preface

    PIP: <to be assigned>
    Title: <PIP title>
    Author: <list of authors’ names and optionally, email addresses>
    Category (*only required for Standard Track): < STO | CORE > 
    Status: Draft
    Created: <date created on, in ISO 8601 (yyyy-mm-dd) format>
    Requires (*optional): <PIP number(s)>
    Replaces (*optional): <PIP number(s)>

## Synopsis
Provide a simplified and layman-accessible explanation of the PIP.

## Abstract
Please provide a short (~200 word) description of the technical issue being addressed.

## Motivation
What motivates you to raise the PIP.PIP submissions without sufficient motivation may be rejected outright.   
If it is a CORE PIP then explain why the current version of the protocol needs to be modified.   

## Specification
The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current polymath platforms (polymath.js ...). If Core contracts need to be modified, explain why and how you would perform those modifications. If necessary submit an additional PIP that deals with CORE modifications.

## Rationale
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages. The rationale may also provide evidence of consensus within the community, and should discuss important objections or concerns raised during discussion.

## Backwards Compatibility
All PIPs that introduce backwards incompatibilities must include a section describing these incompatibilities and their severity. The PIP must explain how the author proposes to deal with these incompatibilities. PIP submissions without a sufficient backwards compatibility treatise may be rejected outright.

## Test Cases
Test cases for an implementation are mandatory for PIPs that are affecting how Core smart contracts work and that would require upgrading or replacing existing Core contracts.

## Implementation
The implementations must be completed before any PIP is given status "Final", but it need not be completed before the PIP is accepted. While there is merit to the approach of reaching consensus on the specification and rationale before writing code.