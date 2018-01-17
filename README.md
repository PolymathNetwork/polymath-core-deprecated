[![Build Status](https://travis-ci.com/PolymathNetwork/polymath-core.svg?token=Urvmqzpy4pAxp6EpzZd6&branch=master)](https://travis-ci.com/PolymathNetwork/polymath-core)
<a href="https://t.me/polymathnetwork"><img src="https://img.shields.io/badge/50k+-telegram-blue.svg" target="_blank"></a>

<!--img src="https://img.shields.io/badge/bounties-1,000,000-green.svg" href="/issues-->

![Polymath](Polymath.png)

# Polymath core

The polymath core smart contracts provide a system for launching regulatory
compliant securities tokens on a decentralized blockchain.

[Read the whitepaper](whitepaper.pdf)

## Live on Ropsten testnet

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [PolyToken](./contracts/PolyToken.sol)                           | [0x17073ed7259d368ced101acdb2ab7eae51b26041](https://ropsten.etherscan.io/address/0x17073ed7259d368ced101acdb2ab7eae51b26041) |
| [Compliance](./contracts/Compliance.sol)                         | [0x522b29bc815ea7c6c881d817f0ae22310bae33e1](https://ropsten.etherscan.io/address/0x522b29bc815ea7c6c881d817f0ae22310bae33e1) |
| [Customers](./contracts/Customers.sol)                           | [0xdc67f93a667d64dbf5ae0d4a7c7758c76346e572](https://ropsten.etherscan.io/address/0xdc67f93a667d64dbf5ae0d4a7c7758c76346e572) |
| [SecurityTokenRegistrar](./contracts/SecurityTokenRegistrar.sol) | [0x81ac3d04f6c19673737ea22813e716d41411678e](https://ropsten.etherscan.io/address/0x81ac3d04f6c19673737ea22813e716d41411678e) |

## Setup

The smart contracts are written in [Solidity][solidity] and tested/deployed
using [Truffle][truffle] version 4.0.0. The new version of Truffle doesn't
require testrpc to be installed separately so you can just do use the following:

```bash
# Install Truffle package globally:
$ npm install -g truffle

# Install local node dependencies:
$ npm install
```

## Testing

To test the code simply run:

```
$ npm run test
```

## Contributing

We're always looking for developers to join the polymath network. To do so we
encourage developers to contribute by creating Security Token Offering contracts
(STO) which can be used by issuers to raise funds. If your contract is used, you
can earn POLY fees directly through the contract, and additional bonuses through
the Polymath reserve fund.

If you would like to apply directly to our STO contract development team, please
send your resume and/or portfolio to careers@polymath.network.

### Styleguide

The polymath-core repo follows the style guide overviewed here:
http://solidity.readthedocs.io/en/develop/style-guide.html

[polymath]: https://polymath.network
[ethereum]: https://www.ethereum.org/
[solidity]: https://solidity.readthedocs.io/en/develop/
[truffle]: http://truffleframework.com/
[testrpc]: https://github.com/ethereumjs/testrpc
