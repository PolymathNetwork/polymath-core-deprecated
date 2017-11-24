
import expectRevert from './helpers/expectRevert';

const PolyTokenMock = artifacts.require('./helpers/PolyTokenMock.sol'); // - ERC20Mock has been renamed to PolyTokenMock - dk - nov 1

contract('ERC20', (accounts) => {
    let token;

    let initialFunds = 10000;  // Initial owner funds
    let transferredFunds = 1200;  // Funds to be transferred around in tests
    let allowedAmount = 100;  // Spender allowance

    let owner = accounts[0];
    let spender = accounts[1];
    let to = accounts[2];

    let balanceOwner;
    let balanceSpender;
    let balanceTo;

    beforeEach(async () => {
        token = await PolyTokenMock.new();

        // Should return 0 balance for owner account
        assert.equal((await token.balanceOf(owner)).toNumber(), 0);

        // Assign tokens to account[0] ('owner')
        await token.assign(owner, initialFunds);

        balanceOwner = (await token.balanceOf(owner)).toNumber();
        balanceSpender = (await token.balanceOf(spender)).toNumber();
        balanceTo = (await token.balanceOf(to)).toNumber();
    });

    describe('construction', async () => {
        it('should return correct initial totalSupply after construction', async () => {
            assert.equal((await token.totalSupply()).toNumber(), 1000000);
        });
    })

    // Tests involving simple transfer() of funds
    // and fetching balanceOf() accounts
    describe('transfer, balanceOf', async () => {
        it('should update balanceOf() after transfer()', async () => {
            await token.transfer(spender, transferredFunds);

            assert.equal((await token.balanceOf(owner)).toNumber(), balanceOwner - transferredFunds);
            assert.equal((await token.balanceOf(spender)).toNumber(), transferredFunds);
        });

        it('should not allow transfer() over balanceOf()', async () => {
            await expectRevert(token.transfer(to, initialFunds + 1));

            await token.assign(owner, 0);
            await expectRevert(token.transfer(to, 1));
        });
    });

    // Tests involving transferring money from A to B via
    // a third account C, which is the one actually making the transfer,
    // using transferFrom()
    describe('approve, allowance, transferFrom', async () => {
        it('should not allow transfer() without approval', async () => {
            await expectRevert(token.transferFrom(owner, spender, 1, {from: spender}));
        });

        it('should not allow approve() without resetting spender allowance to 0', async () => {
            await token.approve(spender, allowedAmount);
            await expectRevert(token.approve(spender, allowedAmount));
            await expectRevert(token.approve(spender, allowedAmount + 1));
        });

        it('should allow approve() multiple times only after resetting spender allowance to 0 in between', async () => {
            await token.approve(spender, allowedAmount);

            await token.approve(spender, 0);
            await token.approve(spender, allowedAmount + 1);
            assert.equal((await token.allowance(owner, spender)).toNumber(), allowedAmount + 1);

            await token.approve(spender, 0);
            await token.approve(spender, allowedAmount - 1);
            assert.equal((await token.allowance(owner, spender)).toNumber(), allowedAmount - 1);

            await token.approve(spender, 0);
            await token.approve(spender, allowedAmount + 1);
            assert.equal((await token.allowance(owner, spender)).toNumber(), allowedAmount + 1);
        });

        it('should return correct allowance() amount after approve()', async () => {
            await token.approve(spender, allowedAmount);
            assert.equal((await token.allowance(owner, spender)).toNumber(), allowedAmount);
        });

        it('should not allow transfer() over approve() amount', async () => {
            await token.approve(spender, allowedAmount - 1);

            let spenderAllowance = (await token.allowance(owner, spender)).toNumber();

            await expectRevert(token.transferFrom(owner, to, allowedAmount, {from: spender}));

            // test balances are unchanged
            assert.equal((await token.balanceOf(owner)).toNumber(), balanceOwner);
            assert.equal((await token.balanceOf(spender)).toNumber(), balanceSpender);
            assert.equal((await token.balanceOf(to)).toNumber(), balanceTo);

            // test allowance is unchanged
            assert.equal((await token.allowance(owner, spender)).toNumber(), spenderAllowance);
        });

        it('should update balanceOf() after transferFrom()', async () => {
            await token.approve(spender, allowedAmount);
            await token.transferFrom(owner, to, allowedAmount / 2, {from: spender});

            assert.equal((await token.balanceOf(owner)).toNumber(), balanceOwner - allowedAmount / 2);
            assert.equal((await token.balanceOf(spender)).toNumber(), balanceSpender);
            assert.equal((await token.balanceOf(to)).toNumber(), balanceTo + allowedAmount / 2);
        });

        it('should reduce transfer() amount from allowance()', async () => {
            await token.approve(spender, allowedAmount);

            let spenderAllowance = (await token.allowance(owner, spender)).toNumber();

            await token.transferFrom(owner, to, allowedAmount / 2, {from: spender});

            assert.equal((await token.allowance(owner, spender)).toNumber(), spenderAllowance / 2);
        });
    });

    describe('events', async () => {
        it('should log Transfer event after transfer()', async () => {
            let result = await token.transfer(spender, transferredFunds);

            assert.lengthOf(result.logs, 1);
            let event = result.logs[0];
            assert.equal(event.event, 'Transfer');
            assert.equal(event.args._from, owner);
            assert.equal(event.args._to, spender);
            assert.equal(Number(event.args._value), transferredFunds);
        });

        it('should log Transfer event after transferFrom()', async () => {
            await token.approve(spender, allowedAmount);

            let value = allowedAmount / 2;
            let result = await token.transferFrom(owner, to, value, {from: spender});

            assert.lengthOf(result.logs, 1);
            let event = result.logs[0];
            assert.equal(event.event, 'Transfer');
            assert.equal(event.args._from, owner);
            assert.equal(event.args._to, to);
            assert.equal(Number(event.args._value), value);
        });

        it('should log Approve event after approve()', async () => {
            let result = await token.approve(spender, allowedAmount);

            assert.lengthOf(result.logs, 1);
            let event = result.logs[0];
            assert.equal(event.event, 'Approval');
            assert.equal(event.args._spender, spender);
            assert.equal(Number(event.args._value), allowedAmount);
        });

    });
});
