import expectRevert from './helpers/expectRevert';
const Ownable = artifacts.require('../contracts/Ownable.sol');

contract('Ownable', (accounts) => {
  let ownable;

  let owner = accounts[0];
  let newOwner = accounts[1];
  let stranger = accounts[2];

  beforeEach(async () => {
    ownable = await Ownable.new();
  });

  describe('construction', async () => {
    it('should have an owner', async () => {
      assert.equal(await ownable.owner(), owner);
    });

    it('should not have a newOwnerCandidate', async () => {
      assert.equal(await ownable.newOwnerCandidate(), 0);
    });
  });

  describe('ownership transfer', async () => {
    it('should update newOwnerCandidate after requestOwnershipTransfer()', async () => {
      await ownable.requestOwnershipTransfer(newOwner);

      assert.equal(await ownable.newOwnerCandidate(), newOwner);
    });

    it('should not update owner without new candidate accepting ownership transfer', async () => {
      await ownable.requestOwnershipTransfer(newOwner);

      assert.equal(await ownable.owner(), owner);
    });

    it('should upate owner after requestOwnershipTransfer() and acceptOwnership()', async () => {
      await ownable.requestOwnershipTransfer(newOwner);
      await ownable.acceptOwnership({from: newOwner});

      assert.equal(await ownable.owner(), newOwner);
      assert.equal(await ownable.newOwnerCandidate(), 0);
    });

    it('should not allow non-owners to requestOwnershipTransfer()', async () => {
      assert((await ownable.owner()) != stranger);

      await expectRevert(ownable.requestOwnershipTransfer(newOwner, {from: stranger}));
    });

    it('should not allow requestOwnershipTransfer() to null or 0 address', async () => {
      await expectRevert(ownable.requestOwnershipTransfer(null, {from: owner}));
      await expectRevert(ownable.requestOwnershipTransfer(0, {from: owner}));

      assert.equal(owner, await ownable.owner());
    });

    it('should not allow strangers to acceptOwnership()', async () => {
      await ownable.requestOwnershipTransfer(newOwner);
      assert.equal(await ownable.newOwnerCandidate(), newOwner);

      await expectRevert(ownable.acceptOwnership({from: stranger}));
      assert.equal(await ownable.newOwnerCandidate(), newOwner);
      assert.equal(await ownable.owner(), owner);
    });

    it('events', async () => {
      let result = await ownable.requestOwnershipTransfer(newOwner);

      assert.lengthOf(result.logs, 1);
      let event = result.logs[0];
      assert.equal(event.event, 'OwnershipRequested');
      assert.equal(event.args._by, owner);
      assert.equal(event.args._to, newOwner);

      result = await ownable.acceptOwnership({from: newOwner});

      assert.lengthOf(result.logs, 1);
      event = result.logs[0];
      assert.equal(event.event, 'OwnershipTransferred');
      assert.equal(event.args._from, owner);
      assert.equal(event.args._to, newOwner);
    });
  });
});
