[![Build Status](https://travis-ci.com/PolymathNetwork/polymath-core.svg?token=Urvmqzpy4pAxp6EpzZd6&branch=master)](https://travis-ci.com/PolymathNetwork/polymath-core)
<img src="https://img.shields.io/badge/chat-telegram-blue.svg" href="https://t.me/polymathnetwork">

<!--img src="https://img.shields.io/badge/bounties-1,000,000-green.svg" href="/issues-->

![Polymath](Polymath.png)

# Polymath core

The polymath core smart contracts provide a system for launching regulatory
compliant securities tokens on a decentralized blockchain.

[Read the whitepaper](whitepaper.pdf)

## Live on Ropsten testnet

| Contract                                                         | Address                                                                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [PolyToken](./contracts/PolyToken.sol)                           | [0xb5173fdf0b21169b33788390465522a0ca184c84](https://ropsten.etherscan.io/address/0xb5173fdf0b21169b33788390465522a0ca184c84) |
| [Compliance](./contracts/Compliance.sol)                         | [0x23f2358b374ee529a3726a5e6186be66805f9cce](https://ropsten.etherscan.io/address/0x23f2358b374ee529a3726a5e6186be66805f9cce) |
| [Customers](./contracts/Customers.sol)                           | [0xfd4bd5029a21e2749e07c877e62e0f49c3e9e01b](https://ropsten.etherscan.io/address/0xfd4bd5029a21e2749e07c877e62e0f49c3e9e01b) |
| [SecurityTokenRegistrar](./contracts/SecurityTokenRegistrar.sol) | [0x33c706a015fc3a4b92dc4462cd51dfe208a50187](https://ropsten.etherscan.io/address/0x33c706a015fc3a4b92dc4462cd51dfe208a50187) |

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
