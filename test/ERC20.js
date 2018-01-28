const POLY = artifacts.require('./helpers/mockContracts/PolyTokenMock.sol');
import {ensureException} from './helpers/utils.js'
const BigNumber = require('bignumber.js');



contract("ERC20", (accounts) => {
    let owner ;
    let holder1;
    let holder2;
    let holder3;
    let holder4;
    let supply = 1000000;
    let trasferFunds = 150;
    let allowedAmount = 200;

    before(async() => {
        owner = accounts[0];
        holder1 = accounts[1];
        holder2 = accounts[2];
        holder3 = accounts[3];
        holder4 = accounts[4]
    });
describe("Constructor", async()=>{
    it("Verify constructors",async()=>{
        let poly = await POLY.new();

        let tokenName = await poly.name.call();
        assert.equal(tokenName.toString(),"Polymath Network");

        let tokenSymbol = await poly.symbol();
        assert.equal(tokenSymbol.toString(),"POLY");

        let tokenSupply = await poly.totalSupply();
        assert.equal(tokenSupply.toNumber(),supply);
    });
});

 describe("transfer", async() => {
    it('transfer: ether directly to the token contract -- it will throw', async() => {
        let poly = await POLY.new();
        try {
            await web3
                .eth
                .sendTransaction({
                    from: holder1,
                    to: poly.address,
                    value: web3.toWei('10', 'Ether')
                });
        } catch (error) {
                ensureException(error);
        }
    });

    it('transfer: should transfer 10000 to holder1 from owner', async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 10000, {from: owner});
        let balance = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(balance.toNumber(), 10000);
    });

    it('transfer: first should transfer 10000 to holder1 from owner then holder1 transfers 1000 to holder2',
    async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 10000, {from: owner});
        let balance = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(balance.toNumber(), 10000);
        await poly.transfer(holder2, 1000, {from: holder1});
        let accBalance = await poly
            .balanceOf
            .call(holder2);
        assert.strictEqual(accBalance.toNumber(), 1000);
    });
 });

 describe("approve", async() => {
    it('approve: holder1 should approve 1000 to holder2', async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 10000, {from: owner});
        await poly.approve(holder2, 1000, {from: holder1});
        let _allowance = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance.toNumber(),1000);
    });

    it('approve: holder1 should approve 1000 to holder2 & withdraws 200 once', async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 1000, {from: owner});
        await poly.approve(holder2, 1000, {from: holder1})
        let _allowance1 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance1.toNumber(), 1000);
        await poly.transferFrom(holder1, holder3, 200, {from: holder2});
        let balance = await poly
            .balanceOf
            .call(holder3);
        assert.strictEqual(balance.toNumber(), 200);
        let _allowance2 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance2.toNumber(), 800);
        let _balance = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(_balance.toNumber(), 800);
    });

    it('approve: holder1 should approve 1000 to holder2 & withdraws 200 twice', async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 1000, {from: owner});
        await poly.approve(holder2, 1000, {from: holder1});
        let _allowance1 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance1.toNumber(), 1000);
        await poly.transferFrom(holder1, holder3, 200, {from: holder2});
        let _balance1 = await poly
            .balanceOf
            .call(holder3);
        assert.strictEqual(_balance1.toNumber(), 200);
        let _allowance2 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance2.toNumber(), 800);
        let _balance2 = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(_balance2.toNumber(), 800);
        await poly.transferFrom(holder1, holder4, 200, {from: holder2});
        let _balance3 = await poly
            .balanceOf
            .call(holder4);
        assert.strictEqual(_balance3.toNumber(), 200);
        let _allowance3 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance3.toNumber(), 600);
        let _balance4 = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(_balance4.toNumber(), 600);
    });

    it('Approve max (2^256 - 1)', async() => {
        let poly = await POLY.new();
        await poly.approve(holder1, '115792089237316195423570985008687907853269984665640564039457584007913129639935', {from: holder2});
        let _allowance = await poly.allowance(holder2, holder1);
        let result = _allowance.equals('1.15792089237316195423570985008687907853269984665640564039457584007913129639935e' +
                '+77');
        assert.isTrue(result);
    });


    it('approves: Holder1 approves Holder2 of 1000 & withdraws 800 & 500 (2nd tx should fail)',
    async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 1000, {from: owner});
        await poly.approve(holder2, 1000, {from: holder1});
        let _allowance1 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance1.toNumber(), 1000);
       await poly.transferFrom(holder1, holder3, 800, {from: holder2});
        let _balance1 = await poly
            .balanceOf
            .call(holder3);
        assert.strictEqual(_balance1.toNumber(), 800);
        let _allowance2 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance2.toNumber(), 200);
        let _balance2 = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(_balance2.toNumber(), 200);
        try {
            await poly.transferFrom(holder1, holder3, 500, {from: holder2});
        } catch (error) {
                ensureException(error);
        }
    });
 });

 describe("trasferFrom", async()=>{
    it('transferFrom: Attempt to  withdraw from account with no allowance  -- fail', async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 1000, {from: owner});
        try {
            await poly
                .transferFrom
                .call(holder1, holder3, 100, {from: holder2});
        } catch (error) {
                ensureException(error);
        }
    });

    it('transferFrom: Allow holder2 1000 to withdraw from holder1. Withdraw 800 and then approve 0 & attempt transfer',
    async() => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.transfer(holder1, 1000, {from: owner});
        await poly.approve(holder2, 1000, {from: holder1});
        let _allowance1 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance1.toNumber(), 1000);
        await poly.transferFrom(holder1, holder3, 200, {from: holder2});
        let _balance1 = await poly
            .balanceOf
            .call(holder3);
        assert.strictEqual(_balance1.toNumber(), 200);
        let _allowance2 = await poly
            .allowance
            .call(holder1, holder2);
        assert.strictEqual(_allowance2.toNumber(), 800);
        let _balance2 = await poly
            .balanceOf
            .call(holder1);
        assert.strictEqual(_balance2.toNumber(), 800);
        await poly.approve(holder2, 0, {from: holder1});
        try {
            await poly.transferFrom(holder1, holder3, 200, {from: holder2});
        } catch (error) {
            ensureException(error);
        }
    });
 });

 describe('events', async () => {
     it('should log Transfer event after transfer()', async () => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        let result = await poly.transfer(holder3, trasferFunds);
    
        assert.lengthOf(result.logs, 1);
        let event = result.logs[0];
        assert.equal(event.event, 'Transfer');
        assert.equal(event.args._from, owner);
        assert.equal(event.args._to, holder3);
        assert.equal(Number(event.args._value), trasferFunds);
      });
    
      it('should log Transfer event after transferFrom()', async () => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        await poly.approve(holder1, allowedAmount,{ from : owner });
    
        let value = allowedAmount / 2;
        let result = await poly.transferFrom(owner, holder2, value, {
            from: holder1,
      });
    
        assert.lengthOf(result.logs, 1);
        let event = result.logs[0];
        assert.equal(event.event, 'Transfer');
        assert.equal(event.args._from, owner);
        assert.equal(event.args._to, holder2);
        assert.equal(Number(event.args._value), value);
      });
    
      it('should log Approve event after approve()', async () => {
        let poly = await POLY.new();
        await poly.getTokens(100000,owner);
        let result = await poly.approve(holder1, allowedAmount,{ from : owner });
    
        assert.lengthOf(result.logs, 1);
        let event = result.logs[0];
        assert.equal(event.event, 'Approval');
        assert.equal(event.args._spender, holder1);
        assert.equal(Number(event.args._value), allowedAmount);
     });
    });

});


