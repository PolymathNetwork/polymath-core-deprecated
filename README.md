# Polymath Security Token Contracts

The smart contracts for Security Token Creation [Polymath][polymath].

![Polymath](bull.svg)

Security Tokens are cryptocurrencies built on top of the [Ethereum][ethereum] blockchain.
They are used to issue securities on the blockchain that are legally compliant with relevant regulatory bodies, depending on where the issuing company is based.

## Contracts

Please see the [contracts/](contracts) directory.

## Develop

Contracts are written in [Solidity][solidity] and tested using [Truffle][truffle] and [testrpc][testrpc].

### Depenencies

```bash
# Install Truffle and testrpc packages globally:
$ npm install -g truffle ethereumjs-testrpc

# Install local node dependencies:
$ npm install
```

### Test
$ truffle test

[polymath]: https://polymath.network
[ethereum]: https://www.ethereum.org/

[solidity]: https://solidity.readthedocs.io/en/develop/
[truffle]: http://truffleframework.com/
[testrpc]: https://github.com/ethereumjs/testrpc
