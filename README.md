[![Build Status](https://travis-ci.com/PolymathNetwork/polymath-core.svg?token=Urvmqzpy4pAxp6EpzZd6&branch=master)](https://travis-ci.com/PolymathNetwork/polymath-core)
<a href="https://t.me/polymathnetwork"><img src="https://img.shields.io/badge/50k+-telegram-blue.svg" target="_blank"></a>

<!--img src="https://img.shields.io/badge/bounties-1,000,000-green.svg" href="/issues-->

![Polymath](Polymath.png)

# Polymath core

The polymath core smart contracts provide a system for launching regulatory
compliant securities tokens on a decentralized blockchain.

[Read the whitepaper](whitepaper.pdf)

## Live on Ethereum Mainnet

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [PolyToken](./contracts/PolyToken.sol)                           | [0x9992eC3cF6A55b00978cdDF2b27BC6882d88D1eC](https://etherscan.io/address/0x9992eC3cF6A55b00978cdDF2b27BC6882d88D1eC) |
| [Compliance](./contracts/Compliance.sol)                         | [0x076719c05961a0c3398e558e2199085d32717ca6](https://etherscan.io/address/0x076719c05961a0c3398e558e2199085d32717ca6) |
| [Customers](./contracts/Customers.sol)                           | [	0xeb30a60c199664ab84dec3f8b72de3badf1837f5](https://etherscan.io/address/0xeb30a60c199664ab84dec3f8b72de3badf1837f5) |
| [SecurityTokenRegistrar](./contracts/SecurityTokenRegistrar.sol) | [0x56e30b617c8b4798955b6be6fec706de91352ed0](https://etherscan.io/address/0x56e30b617c8b4798955b6be6fec706de91352ed0) |


## Live on Ropsten testnet

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [PolyToken](./contracts/PolyToken.sol)                           | [0x96a62428509002a7ae5f6ad29e4750d852a3f3d7](https://ropsten.etherscan.io/address/0x96a62428509002a7ae5f6ad29e4750d852a3f3d7) |
| [Compliance](./contracts/Compliance.sol)                         | [0xc2d58fa8970357b650bcecde35ab5dff80843bca](https://ropsten.etherscan.io/address/0xc2d58fa8970357b650bcecde35ab5dff80843bca) |
| [Customers](./contracts/Customers.sol)                           | [0x140be31172742c14e3a8c152d6531a2215a1c3f8](https://ropsten.etherscan.io/address/0x140be31172742c14e3a8c152d6531a2215a1c3f8) |
| [SecurityTokenRegistrar](./contracts/SecurityTokenRegistrar.sol) | [0x012add44bfb3211ccb06c52d8d645d9eb187a89c](https://ropsten.etherscan.io/address/0x012add44bfb3211ccb06c52d8d645d9eb187a89c) |

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
