import expectRevert from './helpers/expectRevert';

const Compliance = artifacts.require('../contracts/Customers.sol');
const POLY = artifacts.require('../contracts/PolyToken.sol');
const Customers = artifacts.require('../contracts/Customers.sol');
const BigNumber = require('bignumber.js');
let Utils = require('./helpers/Utils');


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
    const providerName1 = "KYC-Chain"
    const providerName2 = "Uport"
    const providerApplication1 = "0xlfkeGlsdjs"
    const providerApplication2 = "0xlfsvrgeX"

    beforeEach(async () => {
        let compliance = await Compliance.new.apply(this)
        let poly = await POLY.new.apply(this)
        let customers = await Customers.new.apply(this, [poly.address])
        // Gas issues with this line
        let customer = await customers.newCustomer(jurisdiction0, attestor1, customerInvestorRole, witnessProof1);
    });

    describe('function newCustomer', async () => {
        it('it should successfully add the newCustomer in the storage',async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            let customer = await customers.newCustomer(jurisdiction0,provider1,customerInvestorRole,witnessProof1);
            assert.isTrue(customer);
        });
    });

    describe("function verifyCustomer", async () => {

        it('if a KYC provider is expired or unnapproved, they cant verify customers', async () => {
            
        });

        it('An approved and active KYC provider can validate customers as being in a jurisdiction and accredit a customer', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            await poly.getTokens(1000000,{from:provider1});
            await poly.approve(owner,100000,{from:provider1});
            let provider = await customers
                                .newProvider(provider1,providerName1,providerApplication1,100,{
                                from:owner,
                            });
            let customer = await customers.newCustomer(
                                jurisdiction0,
                                provider1,
                                customerInvestorRole,
                                witnessProof1,
                                {
                                    from:customer1
                                });
            let isVerify = await customers.verifyCustomer(
                                customer1,
                                jurisdiction0,
                                customerInvestorRole,
                                true,
                                witnessProof1,
                                expcurrentTime + 172800,         // 2 days more than current time
                                {
                                    from:provider1
                                });
            assert.isTrue(isVerify);
        });

        it('Ensure KYC providers can only approve a customer if they were chosen to represent them by the customer', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            await poly.getTokens(1000000,{from:provider1});
            await poly.approve(owner,100000,{from:provider1});
            let provider = await customers
                                .newProvider(provider2,providerName2,providerApplication2,100,{
                                from:owner,
                            });
            let provider = await customers
                                .newProvider(provider1,providerName1,providerApplication1,100,{
                                from:owner,
                            });
            let customer = await customers.newCustomer(
                                jurisdiction0,
                                provider1,
                                customerInvestorRole,
                                witnessProof1,
                                {
                                    from:customer1
                                });
            try {
                let isVerify = await customers.verifyCustomer(
                    customer1,
                    jurisdiction0,
                    customerInvestorRole,
                    true,
                    witnessProof1,
                    expcurrentTime + 172800,         // 2 days more than current time
                    {
                        from:provider2
                    });
            } catch(error) {
                Utils.ensureException(error);
            }
        });
    })

    describe("function newProvider", async () => {
        
        it('KYC providers can apply their data to the chain', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            await poly.getTokens(1000000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),1000000);
            await poly.approve(owner,100000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,owner);
            assert.strictEqual(allowedToken.toNumber(),100000);
            let provider = await customers
                                .newProvider(provider1,providerName1,providerApplication1,100,{
                                    from:owner,
                                    });
            let providerDetails = await customers.getProvider.call(provider1);
            console.log(providerDetails);
            assert.strictEqual(providerDetails.name,providerName1);    
        });

        it('kyc providers apply their data to chain -- fail because of zero address',async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            await poly.getTokens(1000000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),1000000);
            await poly.approve(owner,100000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,owner);
            assert.strictEqual(allowedToken.toNumber(),100000);
            try {                
                await customers
                            .newProvider(0x0,providerName1,providerApplication1,100,{
                                from:owner,
                            });
            } catch(error){
                return Utils.ensureException(error);
            } 
        });
        it('kyc providers apply their data to chain -- fail because of less balance',async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            await poly.getTokens(100000,{from:provider1});
            let providerBalance = await poly.balanceOf.call(provider1);
            assert.strictEqual(providerBalance.toNumber(),100000);
            await poly.approve(owner,1000,{from:provider1});
            let allowedToken = await poly.allowance.call(provider1,owner);
            assert.strictEqual(allowedToken.toNumber(),1000);
            try {                
                    await customers
                                .newProvider(provider1,providerName1,providerApplication1,100,{
                                    from:owner,
                                });
            } catch(error){
                return Utils.ensureException(error);
            }   
        });
    })
    describe("function approveProvider", async () => {

        it('should allow delete a KYC provider if unapproved', async () => {

        });

        it('should allow only owner to call approve provider', async () => {

        });
        it('owner cant delete a KYC provider if they have been approved, even if they were later unapproved or expired', async () => {

        });
    })
});
