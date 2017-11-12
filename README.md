# Polymath Smart Contracts

The Ethereum smart contracts for [Polymath][polymath], the securities token platform. Currently deployed to:

## Ropsten

| Contract       | Address                                    |
| :-------------| :-----------------------------------------:|
| [PolyToken](./contracts/PolyToken.sol)     | [0xd6f78e055bb0137d6c2ee799d59defcfe032b1a7](https://ropsten.etherscan.io/address/0xd6f78e055bb0137d6c2ee799d59defcfe032b1a7) |
| [SecurityTokens](./contracts/SecurityTokens.sol) | [0x2e6eb6009832a0e1f1ffe970dbe1ea44ff4b5461](https://ropsten.etherscan.io/address/0x2e6eb6009832a0e1f1ffe970dbe1ea44ff4b5461) |
| [SecurityToken](./contracts/SecurityToken.sol)  | [0xbc2a5cc6e723a829d231b207e8ec0c0a8e573c93](https://ropsten.etherscan.io/address/0xbc2a5cc6e723a829d231b207e8ec0c0a8e573c93) |
| [Compliance](./contracts/Compliance.sol)     | [0xcc1f38392f98443b1d25947be91c595ea4e78210](https://ropsten.etherscan.io/address/0xcc1f38392f98443b1d25947be91c595ea4e78210) |
| [Customers](./contracts/Customers.sol)      | [0xbe40f369c413a2c7eaab9d9cc85cfc1dbe664ec6](https://ropsten.etherscan.io/address/0xbe40f369c413a2c7eaab9d9cc85cfc1dbe664ec6) |

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

## Style Guide 

The style guide for Polymath follows the style guide laid out by the Solidity Team at: http://solidity.readthedocs.io/en/develop/style-guide.html

## Linting 
 
Solium is used as the linter for solidity code. You can see the code for solium here: https://github.com/duaraghav8/Solium

Solium creates two files:

| File       | Purpose                                    |
| :-------------| :-----------------------------------------:|
| [.soliumignore](./soliumignore)     | [contains names of files and directories to ignore while linting.]|
| [.soliumrc.json](./soliumrc.json) | [contains configuration that tells solium how to lint your project. It can be  modified to configure rules, plugins and sharable configs] |

![Polymath](Polymath.png)

Copyright © 2017 Polymath Inc.

[polymath]: https://polymath.network
[ethereum]: https://www.ethereum.org/

[solidity]: https://solidity.readthedocs.io/en/develop/
[truffle]: http://truffleframework.com/
[testrpc]: https://github.com/ethereumjs/testrpc
