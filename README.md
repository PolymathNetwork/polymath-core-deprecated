# Polymath Smart Contracts

The Ethereum smart contracts for [Polymath][polymath], the securities token platform. Currently deployed to:

## Ropsten

| Contract       | Address                                    |
| :-------------| :-----------------------------------------:|
| [PolyToken](./contracts/PolyToken.sol)     | [0xb01b5e6d5648104f08498a25d97bf90d4c69759f](https://ropsten.etherscan.io/address/0xb01b5e6d5648104f08498a25d97bf90d4c69759f) |
| [SecurityTokens](./contracts/SecurityTokens.sol) | [0xe79af7d86cf086e330d3578648a293cecdb4be5b](https://ropsten.etherscan.io/address/0xe79af7d86cf086e330d3578648a293cecdb4be5b) |
| [SecurityToken](./contracts/SecurityToken.sol)  | [0x11a168c04ed3f5d8c0b75a5e07a54d07d73ccb57](https://ropsten.etherscan.io/address/0x11a168c04ed3f5d8c0b75a5e07a54d07d73ccb57) |
| [Compliance](./contracts/Compliance.sol)     | [0x36649046872a80e2e0d383d6782b8ae9ede0a2ab](https://ropsten.etherscan.io/address/0x36649046872a80e2e0d383d6782b8ae9ede0a2ab) |
| [Customers](./contracts/Customers.sol)      | [0x472edfd8766fec5850fa2900a284d49f1063f67a](https://ropsten.etherscan.io/address/0x472edfd8766fec5850fa2900a284d49f1063f67a) |

## Setup

Contracts are written in [Solidity][solidity] and tested using [Truffle][truffle] version 4.0.0 and [testrpc][testrpc].
The new version of Truffle doesn't require testrpc.

```bash
# Install Truffle package globally:
$ npm install -g truffle@beta

# Install local node dependencies:
$ npm install
```

## Testing

To test the codebase simply run:

```
$ npm run test
```

![Polymath](Polymath.png)

Copyright © 2017 Polymath Inc.

[polymath]: https://polymath.network
[ethereum]: https://www.ethereum.org/

[solidity]: https://solidity.readthedocs.io/en/develop/
[truffle]: http://truffleframework.com/
[testrpc]: https://github.com/ethereumjs/testrpc
