![Polymath](Polymath.png)

## Polymath core smart contracts

<img src="https://travis-ci.com/PolymathNetwork/polymath-core.svg?token=Urvmqzpy4pAxp6EpzZd6&branch=add-to-gitignore">

| Contract                                         | Ropsten Testnet Address                                                                                                       |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| [PolyToken](./contracts/PolyToken.sol)           | [0x80423da869f0121a31f73597aaa7fbddd231d8e7](https://ropsten.etherscan.io/address/0x80423da869f0121a31f73597aaa7fbddd231d8e7) |
| [SecurityTokens](./contracts/SecurityTokens.sol) | [0x323121a1728ceaa1ac44dd57ecf519277d888244](https://ropsten.etherscan.io/address/0x323121a1728ceaa1ac44dd57ecf519277d888244) |
| [Compliance](./contracts/Compliance.sol)         | [0x1deaf332c28bb6481ca7b2fa4b08faaa9900bcd4](https://ropsten.etherscan.io/address/0x1deaf332c28bb6481ca7b2fa4b08faaa9900bcd4) |
| [Customers](./contracts/Customers.sol)           | [0x6266f2ee059ed8eb301b16cc845f34de2780133f](https://ropsten.etherscan.io/address/0x6266f2ee059ed8eb301b16cc845f34de2780133f) |

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

We're always open for developers to join the polymath network! To do so we
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
