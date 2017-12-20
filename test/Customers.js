import expectRevert from './helpers/expectRevert';

const Compliance = artifacts.require('../contracts/Customers.sol');
const POLY = artifacts.require('../contracts/PolyToken.sol');
const Customers = artifacts.require('../contracts/Customers.sol');
const BigNumber = require('bignumber.js');
const Utils = require('./helpers/Utils');


contract('Customers', (accounts) => {

    const customersAddress = "0xbe40f369c413a2c7eaab9d9cc85cfc1dbe664ec6"; //hard coded, from testrpc. need to ensure this is repeatable. truffle 4.0 should be like this. i use "hello" for mneumonic if no truffle 4.0    

    //holders for the 4 functions in Customers.sol
    let newCustomerApplication;
    let verifyCustomerApplication;
    let newKycProviderApplication;
    let approveProviderApplication;

    //accounts
    let owner = accounts[0];
    let customer1 = accounts[1];
    let customer2 = accounts[2];
    let provider1 = accounts[3];
    let provider2 = accounts[4];
    let attestor1 = accounts[5];
    let attestor2 = accounts[6];
    
    //newCustomer() constants
    const jurisdiction0 = "0";
    const jurisdiction1 = "1";
    const customerInvestorRole = 1;
    const customerIssuerRole = 2;
    const witnessProof1 = "ASffjflfgffgf";
    const witnessProof2 = "asfretgtredfgsdfd";

    //verifyCustomer() and approveProvider constants
    const expcurrentTime = new Date().getTime() / 1000; //should get time currently
    const willNotExipre = 1577836800; //Jan 1st 2020, to represent a time that won't fail for testing
    const willExpire = 1500000000; //July 14 2017 will expire

    //newProvider() constants
    const providerName1 = "KYC-Chain";
    const providerName2 = "Uport";
    const providerApplication1 = "Details1";
    const providerApplication2 = "Details2";
    const providerFee1 = 1000;
    const providerFee2 = 100;

    beforeEach(async () => {
        let compliance = await Compliance.new.apply(this);
        let poly = await POLY.new.apply(this);
        let customers = await Customers.new.apply(this, [poly.address]);
    });


    describe("function verifyCustomer", async () => {

        it('if a KYC provider is expired or unnapproved, they cant verify customers', async () => {
            
        });

        it('An approved and active KYC provider can validate customers as being in a jurisdiction and accredit a customer', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await poly.getTokens(1000000,{from:provider1});
            await poly.approve(customers.address,100000,{from:provider1});
            await customers.newProvider(provider1,providerName1,providerApplication1,providerFee1);

            await poly.getTokens(10000,{from:customer1});  
            await poly.approve(customers.address,10000,{from:customer1});   

            let isVerify = await customers.verifyCustomer.call(
                                customer1,
                                jurisdiction0,
                                customerInvestorRole,
                                true,
                                expcurrentTime + 172800,         // 2 days more than current time
                                {
                                    from:provider1
                                });
            assert.isTrue(isVerify);
        });

        });

    describe("function newProvider", async () => {
        
        it('KYC providers can apply their data to the chain', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await poly.getTokens(1000000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),1000000);

            await poly.approve(customers.address,100000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,customers.address);
            assert.strictEqual(allowedToken.toNumber(),100000);

            await customers.newProvider(provider1,providerName1,providerApplication1,providerFee1);
            let providerDetails = await customers.getProvider.call(provider1);

            assert.strictEqual(providerDetails[0].toString(),providerName1);    
        });

        it('kyc providers apply their data to chain -- fail because of zero address',async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await poly.getTokens(1000000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),1000000);

            await poly.approve(customers.address,100000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,customers.address);
            assert.strictEqual(allowedToken.toNumber(),100000);

            try {                
                await customers.newProvider(0x0,providerName1,providerApplication1,providerFee1);
           } catch(error) {
                Utils.ensureException(error);
            }
        });

        it('kyc providers apply their data to chain -- fail because of zero details',async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await poly.getTokens(1000000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),1000000);

            await poly.approve(customers.address,100000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,customers.address);
            assert.strictEqual(allowedToken.toNumber(),100000);

            try {                
                await customers.newProvider(provider1,providerName1,0,providerFee1);
           } catch(error) {
                Utils.ensureException(error);
            }
        });

        it('kyc providers apply their data to chain -- fail because of less balance',async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await poly.getTokens(100000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),100000);

            await poly.approve(customers.address,1000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,customers.address);
            assert.strictEqual(allowedToken.toNumber(),1000);
            try {                
                await customers.newProvider(provider1,providerName1,providerApplication1,100);
            } catch(error){
                Utils.ensureException(error);
            }   
        });
    });

    describe("function changeFee", async () => {

        it('should allow to change the fee by the provider', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await poly.getTokens(100000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),100000);

            await poly.approve(customers.address,1000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,customers.address);
            assert.strictEqual(allowedToken.toNumber(),1000);

            await customers.newProvider(provider1,providerName1,providerApplication1,providerFee1);

            await customers.changeFee(10000,{from:provider1});
            let providerData = await customers.getProvider(provider1);
            assert.strictEqual(providerData[3].toNumber(),10000);

        });
    });
});
