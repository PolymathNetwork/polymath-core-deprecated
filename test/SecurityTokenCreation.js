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

  describe('creation', async () => {
    it('should be ownable', async () => {
      assert.equal(await security.owner(), owner);
    });

    it('should return correct name after creation', async () => {
      assert.equal(await security.name(), name);
    });

    it('should return correct symbol after creation', async () => {
      assert.equal(await security.symbol(), symbol);
    });

    it('should return correct decimal points after creation', async () => {
      assert.equal(await security.decimals(), decimals);
    });

    it('should return correct total supply after creation', async () => {
      assert.equal(await security.totalSupply(), totalSupply);
    });

    it('should allocate the total supply to the owner after creation', async () => {
      assert.equal((await security.balanceOf(owner)).toNumber(), totalSupply);
    });

    it('should restrict transfer of the security to any address', async () => {
      assert.expectRevert(security.transfer(owner, spender));
      assert.expectRevert(security.transfer(owner, to1));
    });

    it('should restrict approval for transfer to any address', async () => {
      assert.expectRevert(security.approve(owner, 1));
      assert.expectRevert(security.approve(spender, 1));
      assert.expectRevert(security.approve(to1, 1));
    });

    it('should restrict transferFrom to any address', async () => {
      assert.expectRevert(security.approve(owner, spender, 1));
    });

    it('should restrict transferFrom to any address', async () => {
      assert.expectRevert(security.approve(owner, spender, 1));
    });

    it('should allow transferring ownership to another address', async () => {
      assert.expectRevert(security.approve(owner, spender, 1));
    });

    it('should allow the ')
  });

It should restrict approve or transferFrom of the security token to any address unless approved
It should allow transferring ownership to a new address
- Only the owner of the contract should be able to add a new regulator
- When a token is transferred to the contract address by accident it can be transferred to to the owners address
- When a token is transferred to the contract address by accident it can not be transferred to to the any other address

});
