import {ensureException, duration}  from './helpers/utils.js';
import latestTime from './helpers/latestTime';

const Compliance = artifacts.require('../contracts/Customers.sol');
const POLY = artifacts.require('../contracts/PolyToken.sol');
const Customers = artifacts.require('../contracts/Customers.sol');
const BigNumber = require('bignumber.js');


contract('Customers', accounts => {
 
  //accounts
  let owner = accounts[0];
  let customer1 = accounts[1];
  let customer2 = accounts[2];
  let provider1 = accounts[3];
  let provider2 = accounts[4];
  let attestor1 = accounts[5];
  let attestor2 = accounts[6];

  //newCustomer() constants
  const jurisdiction0 = '0';
  const jurisdiction1 = '1';
  const customerInvestorRole = 1;
  const customerIssuerRole = 2;

  //verifyCustomer() and approveProvider constants
  const expcurrentTime = latestTime();                    //should get time currently
  const willExipres = latestTime() + duration.days(2);    // After 2 days its customer verification status will expire

  //newProvider() constants
  const providerName1 = 'KYC-Chain';
  const providerName2 = 'Uport';
  const providerApplication1 = 'Details1';
  const providerApplication2 = 'Details2';
  const providerFee1 = 1000;
  const providerFee2 = 100;

  describe('function verifyCustomer', async () => {
    it('An approved and active KYC provider can validate customers as being in a jurisdiction and accredit a customer', async () => {
      let poly = await POLY.new();
      let customers = await Customers.new(poly.address);
    
      await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1,
      );
      // Providing allowance to the customer contract address to spend the POLY of Customer
      await poly.getTokens(10000, customer1, { from: customer1 });
      await poly.approve(customers.address, 10000, { from: customer1 });

      let isVerify = await customers.verifyCustomer.call(
        customer1,
        jurisdiction0,
        customerInvestorRole,
        true,
        willExipres, // 2 days more than current time
        {
          from: provider1,
        },
      );
      assert.isTrue(isVerify);
    });

    it('verifyCustomer: An approved and active KYC provider can validate customers as being in a jurisdiction and accredit a customer -- fail due to expiry is less than now', async () => {
      let poly = await POLY.new();
      let customers = await Customers.new(poly.address);

      await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1,
      );
      // Providing allowance to the customer contract address to spend the POLY of Customer
      await poly.getTokens(10000, customer1, { from: customer1 });
      await poly.approve(customers.address, 10000, { from: customer1 });
      try {
        let isVerify = await customers.verifyCustomer.call(
          customer1,
          jurisdiction0,
          customerInvestorRole,
          true,
          (latestTime() - duration.hours(1)), // 1 hour before current time
          {
            from: provider1,
          },
        );
    } catch(error) {
        ensureException(error);
    }
    });

    it('VerifyCustomer: Should fail due to the msg.sender is not provider', async () => {
      let poly = await POLY.new();
      let customers = await Customers.new(poly.address);

      let providerOne = await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1,
      );
      // Providing allowance to the customer contract address to spend the POLY of Customer
      await poly.getTokens(10000, customer1, { from: customer1 });
      await poly.approve(customers.address, 10000, { from: customer1 });

      try {
        let isVerify = await customers.verifyCustomer(
          customer1,
          jurisdiction0,
          customerInvestorRole,
          true,
          willExipres, // 2 days more than current time
          {
            from: customer2,
          },
        );
      } catch (error) {
          ensureException(error);
      }
    });
  });

  describe('function newProvider', async () => {
    it('newProvider: Should register the new KYC providers', async () => {
      let poly = await POLY.new();
      let customers = await Customers.new(poly.address);

      await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1,
      );
      let providerDetails = await customers.getProvider.call(provider1);
      assert.strictEqual(providerDetails[0].toString(), providerName1);   // providerName1 = KYC-Chain
    });

    it('newProvider: should kyc providers apply their data to chain -- fail because of zero address', async () => {
      let poly = await POLY.new();
      let customers = await Customers.new(poly.address);

      try {
        await customers.newProvider(
          0x0,                              // fail because of the 0x0 address instead of the provider address 
          providerName1,
          providerApplication1,
          providerFee1,
        );
      } catch (error) {
            ensureException(error);
      }
    });

    it('newProvider: should kyc providers apply their data to chain -- fail because of zero details', async () => {
      let poly = await POLY.new();
      let customers = await Customers.new(poly.address);

      try {
        await customers.newProvider(
          provider1,
          providerName1,
          0x0,                                              // Failed because details are zero 
          providerFee1,
        );
      } catch (error) {
          ensureException(error);
      }
    });

  });

    describe("function changeFee", async () => {

        it('changeFee: Should allow to change the fee by the provider', async () => {
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);

            await customers.newProvider(
              provider1,
              providerName1,
              providerApplication1,
              providerFee1
            );

            await customers.changeFee(10000,{ from : provider1 });
            let providerData = await customers.getProvider(provider1);
            assert.strictEqual(providerData[3].toNumber(),10000);
    });

        it("changeFee: Should verify the customer with old fee then after change verify the new customer with new fee",async()=>{
            let poly = await POLY.new();
            let customers = await Customers.new(poly.address);
            
            await customers.newProvider(
              provider1,
              providerName1,
              providerApplication1,
              providerFee1
            );

            // Providing allowance to the customer contract address to spend the POLY of Customer1
            await poly.getTokens(10000, customer1, { from: customer1 });
            await poly.approve(customers.address, 10000, { from: customer1 });

            let isVerifyTry1 = await customers.verifyCustomer(
              customer1,
              jurisdiction0,
              customerInvestorRole,
              true,
              willExipres, // 2 days more than current time
              {
                from: provider1,
              },
            );
            
            assert.strictEqual(isVerifyTry1.logs[0].args.customer, customer1);
            // Providing allowance to the customer contract address to spend the POLY of Customer2
            await poly.getTokens(10000, customer2, { from: customer2 });
            await poly.approve(customers.address, 10000, { from: customer2 });
            // Change fee that is charged by the provider 
            await customers.changeFee(10000,{ from : provider1 });
            let providerData = await customers.getProvider(provider1);
            assert.strictEqual(providerData[3].toNumber(),10000);

            let isVerifyTry2 = await customers.verifyCustomer(
              customer2,
              jurisdiction0,
              customerInvestorRole,
              true,
              willExipres, // 2 days more than current time
              {
                from: provider1,
              },
            );
            assert.strictEqual(isVerifyTry2.logs[0].args.customer, customer2);
          });

  });
});
