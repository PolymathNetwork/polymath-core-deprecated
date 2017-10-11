import expectRevert from './helpers/expectRevert';

const SecurityToken = artifacts.require('../contracts/SecurityToken.sol');

contract('SecurityToken', (accounts) => {

  let security;

  const name = 'Polymath Inc.';
  const symbol = 'POLY';
  const decimals = 1;
  const totalSupply = 1234567890;

  let owner = accounts[0];
  let spender = accounts[1];
  let to1 = accounts[2];
  let to2 = accounts[3];
  let to3 = accounts[4];

  let allowedAmount = 100;  // Spender allowance
  let transferredFunds = 1200;  // Funds to be transferred around in tests

  beforeEach(async () => {
    security = await SecurityToken.new();
  });

  describe('approval', async () => {
    it('should log mint event after minting', async () => {
      let result = await token.mint(to1, transferredFunds);

      assert.lengthOf(result.logs, 1);
      let event = result.logs[0];
      assert.equal(event.event, 'Transfer');
      assert.equal(event.args.from, 0);
      assert.equal(event.args.to, to1);
      assert.equal(Number(event.args.value), transferredFunds);
    });

    it('should log minting ended event after minting has ended', async () => {
      let result = await token.endMinting();

      assert.lengthOf(result.logs, 1);
      assert.equal(result.logs[0].event, 'MintingEnded');

            // Additional calls should not emit events.
      result = await token.endMinting();
      assert.equal(result.logs.length, 0);
      result = await token.endMinting();
      assert.equal(result.logs.length, 0);
    });
  });
});
