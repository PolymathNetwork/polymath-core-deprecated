[![Build Status](https://travis-ci.com/PolymathNetwork/polymath-core.svg?token=Urvmqzpy4pAxp6EpzZd6&branch=master)](https://travis-ci.com/PolymathNetwork/polymath-core)
<a href="https://t.me/polymathnetwork"><img src="https://img.shields.io/badge/40k+-telegram-blue.svg" target="_blank"></a>

<!--img src="https://img.shields.io/badge/bounties-1,000,000-green.svg" href="/issues-->

![Polymath](Polymath.png)

# Polymath core

The polymath core smart contracts provide a system for launching regulatory
compliant securities tokens on a decentralized blockchain.

[Read the whitepaper](whitepaper.pdf)

## Live on Ropsten testnet

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [PolyToken](./contracts/PolyToken.sol)                           | [0x3d84b2808d923b69c75a12d35f648849a28f32f2](https://ropsten.etherscan.io/address/0x3d84b2808d923b69c75a12d35f648849a28f32f2) |
| [Compliance](./contracts/Compliance.sol)                         | [0x6e6db7838404ffa6bdd2bc175b82488205120712](https://ropsten.etherscan.io/address/0x6e6db7838404ffa6bdd2bc175b82488205120712) |
| [Customers](./contracts/Customers.sol)                           | [0x4844f78b1cd76cd45e4289d6e9409f38252a7fd4](https://ropsten.etherscan.io/address/0x4844f78b1cd76cd45e4289d6e9409f38252a7fd4) |
| [SecurityTokenRegistrar](./contracts/SecurityTokenRegistrar.sol) | [0x6051ba9f1c2b177f41741ff69ce553b398a058ff](https://ropsten.etherscan.io/address/0x6051ba9f1c2b177f41741ff69ce553b398a058ff) |

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
