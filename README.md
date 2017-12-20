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
| [PolyToken](./contracts/PolyToken.sol)                           | [0xe0568e7158dd961b63b4d733df3db5749fa73bb8](https://ropsten.etherscan.io/address/0xe0568e7158dd961b63b4d733df3db5749fa73bb8) |
| [Compliance](./contracts/Compliance.sol)                         | [0x6ebecdeddac4698a1fa8c7164b967a600cee1b49](https://ropsten.etherscan.io/address/0x6ebecdeddac4698a1fa8c7164b967a600cee1b49) |
| [Customers](./contracts/Customers.sol)                           | [0x5a918a1689bb80c1c11220958dd8a98f25394e76](https://ropsten.etherscan.io/address/0x5a918a1689bb80c1c11220958dd8a98f25394e76) |
| [SecurityTokenRegistrar](./contracts/SecurityTokenRegistrar.sol) | [0x941e9d669db4bfc61d290760fcf571da077555b5](https://ropsten.etherscan.io/address/0x941e9d669db4bfc61d290760fcf571da077555b5) |

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
