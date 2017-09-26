# Polymath Security Token Contracts

The smart contracts for Security Tokens on the [Polymath Network][polymath].

![Polymath](Polymath.png)

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

The current source code is running on the beta and latest version of Truffle which is Beta 4.0.0.

In order to install it:

```bash
# Install Truffle globally:
$ npm install -g truffle@beta

```

The new version of Truffle doesn't require testrpc.

### Test
$ truffle test

[polymath]: https://polymath.network
[ethereum]: https://www.ethereum.org/

[solidity]: https://solidity.readthedocs.io/en/develop/
[truffle]: http://truffleframework.com/
[testrpc]: https://github.com/ethereumjs/testrpc
