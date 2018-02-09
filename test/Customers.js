import {ensureException, duration}  from './helpers/utils.js';
import latestTime from './helpers/latestTime';
import {web3StringToBytes32, signData} from './helpers/signData';
import { pk }  from './helpers/testprivateKey';

const Compliance = artifacts.require('Customers.sol');
const POLY = artifacts.require('./helpers/mockContracts/PolyTokenMock.sol');
const Customers = artifacts.require('Customers.sol');
const BigNumber = require('bignumber.js');

const ethers = require('ethers');
const utils = ethers.utils;
const ethUtil = require('ethereumjs-util');

contract('Customers', accounts => {

  //accounts
  let owner = accounts[0];
  let customer1 = accounts[1];
  let customer2 = accounts[2];
  let provider1 = accounts[3];
  let provider2 = accounts[4];
  let attestor1 = accounts[5];
  let attestor2 = accounts[6];
  let pk_customer1 = pk.account_1;
  let pk_customer2 = pk.account_2;
  
  //newCustomer() constants
  const jurisdiction0 = '0';
  const jurisdiction0_0 = '0_1';
  const jurisdiction1 = '1';
  const jurisdiction1_0 = '1_1';
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

      let nonce = 1;
      const sig = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer1);

      const r = `0x${sig.r.toString('hex')}`;
      const s = `0x${sig.s.toString('hex')}`;
      const v = sig.v;
      
      let isVerify = await customers.verifyCustomer(
        customer1,
        web3StringToBytes32(jurisdiction0),
        web3StringToBytes32(jurisdiction0_0),
        customerInvestorRole,
        true,
        willExipres, // 2 days more than current time
        nonce,
        v,
        r,
        s,
        {
          from: provider1,
        },
      );
    });

    it('An approved and active KYC provider can validate customers twice with nonce increment', async () => {
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

      let nonce = 1;
      const sig = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer1);

      const r = `0x${sig.r.toString('hex')}`;
      const s = `0x${sig.s.toString('hex')}`;
      const v = sig.v;

      let isVerify = await customers.verifyCustomer(
        customer1,
        web3StringToBytes32(jurisdiction0),
        web3StringToBytes32(jurisdiction0_0),
        customerInvestorRole,
        true,
        willExipres, // 2 days more than current time
        nonce,
        v,
        r,
        s,
        {
          from: provider1,
        },
      );

      let nonce2 = 2;
      const sig2 = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce2, pk_customer1);

      const r2 = `0x${sig2.r.toString('hex')}`;
      const s2 = `0x${sig2.s.toString('hex')}`;
      const v2 = sig2.v;

      let isVerify2 = await customers.verifyCustomer(
        customer1,
        web3StringToBytes32(jurisdiction0),
        web3StringToBytes32(jurisdiction0_0),
        customerInvestorRole,
        true,
        willExipres, // 2 days more than current time
        nonce2,
        v2,
        r2,
        s2,
        {
          from: provider1,
        },
      );

    });

    it('An approved and active KYC provider cannot reuse nonce signature', async () => {
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

      let nonce = 1;
      const sig = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer1);

      const r = `0x${sig.r.toString('hex')}`;
      const s = `0x${sig.s.toString('hex')}`;
      const v = sig.v;

      let isVerify = await customers.verifyCustomer(
        customer1,
        web3StringToBytes32(jurisdiction0),
        web3StringToBytes32(jurisdiction0_0),
        customerInvestorRole,
        true,
        willExipres, // 2 days more than current time
        nonce,
        v,
        r,
        s,
        {
          from: provider1,
        },
      );

      // let nonce2 = 1;
      // const sig2 = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, '2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201');
      //
      // const r2 = `0x${sig2.r.toString('hex')}`;
      // const s2 = `0x${sig2.s.toString('hex')}`;
      // const v2 = sig.v;

      try {

        let isVerify = await customers.verifyCustomer(
          customer1,
          web3StringToBytes32(jurisdiction0),
          web3StringToBytes32(jurisdiction0_0),
          customerInvestorRole,
          true,
          willExipres, // 2 days more than current time
          nonce,
          v,
          r,
          s,
          {
            from: provider1,
          },
        );
      } catch(error) {
          ensureException(error);
      }


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

      let nonce = 1;
      const sig = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer1);

      const r = `0x${sig.r.toString('hex')}`;
      const s = `0x${sig.s.toString('hex')}`;
      const v = sig.v;

      try {
        let isVerify = await customers.verifyCustomer.call(
          customer1,
          web3StringToBytes32(jurisdiction0),
          web3StringToBytes32(jurisdiction0_0),
          customerInvestorRole,
          true,
          (latestTime() - duration.hours(1)), // 1 hour before current time
          nonce,
          v,
          r,
          s,
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

      let nonce = 1;
      const sig = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer1);

      const r = `0x${sig.r.toString('hex')}`;
      const s = `0x${sig.s.toString('hex')}`;
      const v = sig.v;

      try {
        let isVerify = await customers.verifyCustomer(
          customer1,
          web3StringToBytes32(jurisdiction0),
          web3StringToBytes32(jurisdiction0_0),
          customerInvestorRole,
          true,
          willExipres, // 2 days more than current time
          nonce,
          v,
          r,
          s,
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

            let nonce = 1;
            const sig = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer1);

            const r = `0x${sig.r.toString('hex')}`;
            const s = `0x${sig.s.toString('hex')}`;
            const v = sig.v;

            let isVerifyTry1 = await customers.verifyCustomer(
              customer1,
              web3StringToBytes32(jurisdiction0),
              web3StringToBytes32(jurisdiction0_0),
              customerInvestorRole,
              true,
              willExipres, // 2 days more than current time
              nonce,
              v,
              r,
              s,
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

            const sig2 = signData(customers.address, provider1, jurisdiction0, jurisdiction0_0, customerInvestorRole, true, nonce, pk_customer2);

            const r2 = `0x${sig2.r.toString('hex')}`;
            const s2 = `0x${sig2.s.toString('hex')}`;
            const v2 = sig2.v;

            let isVerifyTry2 = await customers.verifyCustomer(
              customer2,
              web3StringToBytes32(jurisdiction0),
              web3StringToBytes32(jurisdiction0_0),
              customerInvestorRole,
              true,
              willExipres, // 2 days more than current time
              nonce,
              v2,
              r2,
              s2,
              {
                from: provider1,
              },
            );
            assert.strictEqual(isVerifyTry2.logs[0].args.customer, customer2);
          });

  });
});
