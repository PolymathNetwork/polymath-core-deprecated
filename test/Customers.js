import expectRevert from './helpers/expectRevert';

const Compliance = artifacts.require('../contracts/Customers.sol');
const POLY = artifacts.require('../contracts/PolyToken.sol');
const Customers = artifacts.require('../contracts/Customers.sol');


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
        let customer = await customers.newCustomer(jurisdiction0, attestor1, customerInvestorRole, witnessProof1)
    });

    describe('function newCustomer', async () => {
    });

    describe("function verifyCustomer", async () => {

        it('if a KYC provider is expired or unnapproved, they cant verify customers', async () => {
            
        });

        it('An approved and active KYC provider can validate customers as being in a jurisdiction and accredit a customer', async () => {

        });
        it('Ensure KYC providers can only approve a customer if they were chosen to represent them by the customer', async () => {

        });
    })

    describe("function newProvider", async () => {

        it('KYC providers can apply their data to the chain', async () => {

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
