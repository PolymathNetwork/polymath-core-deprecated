## What is Role ?

Polymath platform user identify according to the roles it possesed.   
Role is an unique integer which is used to identify the actor for what it
authorized at Polymath platform.

## Types of Roles

Polymath platfrom have 4 types of different roles for different actors

| Role | Actor |
|------|-------|
| 0 | Blacklist |
| 1 | Investor|
| 2 | Delegate |
| 3 | Issuer |
| 4 | MarketMaker |

## Actor Defination
__Blacklist__ : Actors blacklisted from holding/transfering a security token.

__Investor__ : Invest their capital in the security token offering at Polymath Platform.

__Issuer__ : Raise funds through Polymath via Security Token Offerings.  

__Delegate__ : Authorized persons or organisations to represent the issuers.  

__MarketMaker__ : Liquidity provider.  

## Where Roles used in Polymath-core
`Template.addRoles` used to adding roles into `Template.allowedRoles` mapping.  
Only allowed roles can participate in the security token offering.
