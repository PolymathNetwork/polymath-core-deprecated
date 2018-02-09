import should from 'should';
import { increaseTime, takeSnapshot, revertToSnapshot } from './helpers/time';
import latestTime from './helpers/latestTime';
import { ensureException, convertHex, duration } from './helpers/utils';
import {web3StringToBytes32, signData} from './helpers/signData';
import { pk }  from './helpers/testprivateKey';

const SecurityToken = artifacts.require('SecurityToken.sol');
const Template = artifacts.require('Template.sol');
const PolyToken = artifacts.require('./helpers/mockContracts/PolyTokenMock.sol');
const Customers = artifacts.require('Customers.sol');
const Compliance = artifacts.require('Compliance.sol');
const Registrar = artifacts.require('SecurityTokenRegistrar.sol');
const SimpleCappedOfferingFactory = artifacts.require('SimpleCappedOfferingFactory.sol');
const SimpleCappedOffering = artifacts.require('SimpleCappedOffering.sol');
const BigNumber = web3.BigNumber;

const ethers = require('ethers');
const utils = ethers.utils;
const ethUtil = require('ethereumjs-util');

contract('SecurityToken', accounts => {

  //accounts
  //let issuer = accounts[1];
  let stoCreator = accounts[2];
  let host = accounts[3];
  let issuer = accounts[4];
  let delegate0 = accounts[5];
  let delegate1 = accounts[6];
  let investor2 = accounts[7];
  let investor1 = accounts[8];
  let provider0 = accounts[9];
  let provider1 = accounts[0];
  let polyFeeAddress = accounts[6];
  const pk_issuer = pk.account_4;
  const pk_delegate0 = pk.account_5;
  const pk_delegate1 = pk.account_6;
  const pk_investor2 = pk.account_7;
  const pk_investor1 = pk.account_8;
  const pk_provider0 = pk.account_9;
  const pk_provider1 = pk.account_0;
  // let fee = 10000;

  const nameSpace = "TestNameSpace";
  const nameSpaceFee = 10000;
  const nameSpaceOwner = accounts[6];

  //roles
  const delegateRole = 2;

  //attestor details
  let details0 = 'delegate1details';
  let details1 = 'attestor2details';
  let delegate0Fee = 100;
  let delegate1Fee = 200;

  //newCustomer() constants
  const jurisdiction0 = '0';
  const jurisdiction0_0 = '0_1';
  const jurisdiction1 = '1';
  const jurisdiction1_0 = '1_1';
  const customerInvestorRole = 1;
  const customerIssuerRole = 3;
  const witnessProof0 = 'ASffjflfgffgf';
  const witnessProof1 = 'asfretgtredfgsdfd';

  //verifyCustomer() and approveProvider constants
  const expcurrentTime = latestTime();                               // Current Time
  const willExpires = latestTime() + duration.days(2);               // Current time + 1 year more
  const startTime = latestTime() + duration.seconds(5000);           // Start time will be 5000 seconds more than the latest time
  const endTime = startTime + duration.days(30);                     // Add 30 days more

  //newProvider() constants
  const providerName0 = 'KYC-Chain';
  const providerName1 = 'Uport';
  const providerApplication0 = 'application0';
  const providerApplication1 = 'application1';
  const providerFee0 = 1000;
  const providerFee1 = 1000;

  //SecurityToken variables
  const name = 'Polymath Inc.';
  const ticker = 'POLY';
  const totalSupply = 1234567890;
  const maxPoly = 100000;
  const lockupPeriod = latestTime() + duration.years(2);                            // lockup period is current time + 2 years more
  const tempIndex = 0;
  const type = 1;

  //Bid variables
  const expires = 1602288000;
  const quorum = 10;
  const vestingPeriod = 8888888;

  //createTemplate variables
  const offeringType = "Public";
  const issuerJurisdiction = 'canada-ca';
  const accredited = false;
  const kyc = 0x2fe38f0b394b297bc0d86ed6b66286572f5235f9;
  const details = 'going to launch on xx-xx-xx';
  const fee = 1000;

  //Compliance
  let dummySTRegistrar = 0x2fe38f0b394b297bc0d86ed6b66286572f52335f1;

  // STO
  let mockStoFactory = "0x81399dd18c7985a016eb2bb0a1f6aabf0745d667";
  let stoFee = 150;
  let polyTokenRate = 100;
  let investedAmount;
  let POLY, customers, compliance, STRegistrar, securityToken;
  let STAddress, templateAddress, offeringFactory, offeringFactory_2, offeringContract;

    before(async()=>{
      POLY = await PolyToken.new();
      customers = await Customers.new(POLY.address);
      compliance = await Compliance.new(customers.address);
      STRegistrar = await Registrar.new(
        POLY.address,
        customers.address,
        compliance.address
      );
      // Adding the new KYC provider in to the Polymath Platform chain data
      await customers.newProvider(
        provider0,
        providerName0,
        providerApplication0,
        providerFee0
      );
      // Provide approval to the customer contract to register the issuer (This step is performed by the Polymath wizard)
      await POLY.getTokens(100000, issuer, { from : issuer });
      await POLY.approve(customers.address, 10000, { from : issuer });

      let nonce = 1;
      let sig = signData(customers.address, provider0, jurisdiction0, jurisdiction0_0, customerIssuerRole, true, nonce, pk_issuer);

      let r = `0x${sig.r.toString('hex')}`;
      let s = `0x${sig.s.toString('hex')}`;
      let v = sig.v;

      // Adding the new customer in to the Polymath Platform chain data
      await customers.verifyCustomer(
          issuer,
          web3StringToBytes32(jurisdiction0),
          web3StringToBytes32(jurisdiction0_0),
          customerIssuerRole,                     // issuer have issuer role = 3
          true,
          willExpires,                            // 2 days more than current time
          nonce,
          v,
          r,
          s,
          {
              from:provider0
      });

      // Adding the new KYC provider in to the Polymath Platform chain data
      await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1
      );
      // Provide approval to the customer contract to register the investor1 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, investor1, { from : investor1 });
      await POLY.approve(customers.address, 10000, { from : investor1 });

      nonce = 1;
      sig = signData(customers.address, provider0, jurisdiction1, jurisdiction1_0, customerInvestorRole, true, nonce, pk_investor1);

      r = `0x${sig.r.toString('hex')}`;
      s = `0x${sig.s.toString('hex')}`;
      v = sig.v;

      // Adding the new customer in to the Polymath Platform chain data
      await customers.verifyCustomer(
          investor1,
          web3StringToBytes32(jurisdiction1),
          web3StringToBytes32(jurisdiction1_0),
          customerInvestorRole,                           // Having investor role = 1
          true,
          willExpires,                                    // 2 days more than current time
          nonce,
          v,
          r,
          s,
          {
              from:provider0
      });

      // Provide approval to the customer contract to register the investor2 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, investor2, { from : investor2 });
      await POLY.approve(customers.address, 10000, { from : investor2 });

      nonce = 1;
      sig = signData(customers.address, provider0, jurisdiction1, jurisdiction1_0, customerInvestorRole, true, nonce, pk_investor2);

      r = `0x${sig.r.toString('hex')}`;
      s = `0x${sig.s.toString('hex')}`;
      v = sig.v;

      // Adding the new customer in to the Polymath Platform chain data
      await customers.verifyCustomer(
          investor2,
          web3StringToBytes32(jurisdiction1),
          web3StringToBytes32(jurisdiction1_0),
          customerInvestorRole,                           // Having investor role = 1
          true,
          willExpires,                                    // 2 days more than current time
          nonce,
          v,
          r,
          s,
          {
              from:provider0
      });

      // Provide approval to the customer contract to register the delegate0 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, delegate0, { from : delegate0 });
      await POLY.approve(customers.address, 10000, { from : delegate0 });

      nonce = 1;
      sig = signData(customers.address, provider0, jurisdiction1, jurisdiction1_0, delegateRole, true, nonce, pk_delegate0);

      r = `0x${sig.r.toString('hex')}`;
      s = `0x${sig.s.toString('hex')}`;
      v = sig.v;

      // Adding the new customer in to the Polymath Platform chain data
      await customers.verifyCustomer(
          delegate0,
          web3StringToBytes32(jurisdiction1),
          web3StringToBytes32(jurisdiction1_0),
          delegateRole,                                   // Delegate role = 2
          true,
          willExpires,                                    // 2 days more than current time
          nonce,
          v,
          r,
          s,
          {
              from:provider0
      });

      // Provide approval to the customer contract to register the delegate1 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, delegate1, { from : delegate1 });
      await POLY.approve(customers.address, 10000, { from : delegate1 });

      nonce = 1;
      sig = signData(customers.address, provider0, jurisdiction1, jurisdiction1_0, delegateRole, true, nonce, pk_delegate1);

      r = `0x${sig.r.toString('hex')}`;
      s = `0x${sig.s.toString('hex')}`;
      v = sig.v;


      // Adding the new customer in to the Polymath Platform chain data
      await customers.verifyCustomer(
          delegate1,
          web3StringToBytes32(jurisdiction1),
          web3StringToBytes32(jurisdiction1_0),
          delegateRole,                                   // Delegate role = 2
          true,
          willExpires,                                    // 2 days more than current time
          nonce,
          v,
          r,
          s,
          {
              from:provider0
      });

      // Provide approval to the Security Token Registrar contract to create the security token
      // (This step is performed by the Polymath wizard)
      await POLY.getTokens(100000, issuer, { from : issuer });
      await POLY.approve(STRegistrar.address, 100000, { from : issuer });
      let allowedToken = await POLY.allowance(issuer, STRegistrar.address);
      assert.strictEqual(allowedToken.toNumber(), 100000);

      // Create name space
      await STRegistrar.createNameSpace(
        nameSpace,
        nameSpaceOwner,
        nameSpaceFee
      )
      // Creation of the Security Token with the help of SecurityTokenRegistrar contract
      let st = await STRegistrar.createSecurityToken(
          nameSpace,
          name,
          ticker,
          totalSupply,
          0,
          issuer,
          type,
          lockupPeriod,
          quorum,
          {
            from : issuer
          });

      // Grep the address of the security token
      STAddress = await STRegistrar.getSecurityTokenAddress.call(nameSpace, ticker);
      // Accesssing the blueprint using the address of Security Token
      securityToken = await SecurityToken.at(STAddress);

      // Creation of the Template
      let templateCreated = await compliance.createTemplate(
          offeringType,
          issuerJurisdiction,
          accredited,
          provider0,
          details,
          expires,
          1000,
          quorum,
          vestingPeriod,
          {
            from:delegate0
      });

      // Storing the template address in the variable
      templateAddress = templateCreated.logs[0].args._template

    });

    describe("Functions of securityToken", async() =>{
      it("Constructor verify the parameters",async()=>{
        // Match all the constructor parmaeters
        let symbol = await securityToken.symbol();
        assert.strictEqual(symbol.toString(), ticker);

        let securityOwner = await securityToken.owner();
        assert.equal(securityOwner, issuer);

        assert.equal(await securityToken.name(), name);

        assert.equal((await securityToken.decimals()).toNumber(), 0);
        assert.equal((await securityToken.totalSupply()).toNumber(), totalSupply);
        assert.equal((await securityToken.balanceOf(issuer)).toNumber(), totalSupply);
      });

      it("addJurisdiction: Should add the Jurisdiction in template -- fail msg.sender is not owner of template",async()=>{
        // Accesssing the blueprint using the address of template
        let template = await Template.at(templateAddress);
        try {
          await template.addJurisdiction(['1','0'], [true,true], { from : delegate1 });
        } catch(error) {
          ensureException(error);
        }
      });

      it("addJurisdiction: Should add the Jurisdiction in template",async()=>{
        // Accesssing the blueprint using the address of template
        let template = await Template.at(templateAddress);
        // Adding the valid jurisdiction and their status
        await template.addJurisdiction(['1','0'], [true,true], { from : delegate0 });
      });

      it("addRoles: Should add the roles in alowed roles list -- fail msg.sender is not the owner of template",async()=>{
        // Accesssing the blueprint using the address of template
        let template = await Template.at(templateAddress);
        try {
          await template.addRoles([1,2], { from : delegate1 });
        } catch(error) {
          ensureException(error);
        }
      });

      it("addRoles: Should add the roles in alowed roles list",async()=>{
        // Accesssing the blueprint using the address of template
        let template = await Template.at(templateAddress);
        // Adding allowed roles that can paricipate in the offering of the Security Token
        await template.addRoles([1,2], { from : delegate0 });
      });

      it("proposeTemplate: Should proposed the teplate successfully --fails template is not finalized",async()=>{
        try {
          await compliance.proposeTemplate(STAddress, templateAddress, { from : delegate0 });
        } catch (error) {
          ensureException(error);
        }
      });

      it("finalizeTemplate: should finalize the template -- fails msg.sender is not owner of template", async() =>{
        // Accesssing the blueprint using the address of template
        let template = await Template.at(templateAddress);
        try {
          await template.finalizeTemplate({ from : delegate1 });
        } catch(error) {
          ensureException(error);
        }
      });

      it("finalizeTemplate: should finalize the template ", async() =>{
        // Accesssing the blueprint using the address of template
        let template = await Template.at(templateAddress);
        // Freezing the template after that no changes allowed
        await template.finalizeTemplate({ from : delegate0 });
        let details = await template.getTemplateDetails.call();
        assert.isTrue(details[1]);
      });

      it("proposeTemplate: Should proposed the template successfully",async()=>{
        // Proposing the template after finalizing it
        await compliance.proposeTemplate(STAddress, templateAddress, { from : delegate0 });
      });

      it("selectTemplate: should owner of token can select the template",async()=>{
        await POLY.getTokens(100000, issuer, { from : issuer });
        await POLY.transfer(STAddress, 10000, { from : issuer });
        // Opt the template to apply jurisdicion rule on a particular Security Token
        let template = await securityToken.selectTemplate(tempIndex, { from : issuer });

        let data = await securityToken.getTokenDetails();
        assert.strictEqual(data[0], templateAddress);
      });

    it("initialiseOffering: Should not start the offering -- fail offering contract is not selected yet", async()=>{
      try {
        await securityToken.initialiseOffering(startTime, endTime, 100, maxPoly, { from : host});
      } catch (error) {
        ensureException(error);
      }
     });

    it("selectOfferingFactory: select the offering factory for the security token",async()=>{
      // Creation of new offering contract to facilitate the distribution of the Security token
      offeringFactory = await SimpleCappedOfferingFactory.new({ from : issuer, gas : 5000000 });
      // Assign all the essentials of the offering contract by its owner
      // await stoContract.securityTokenOffering(securityToken.address, startTime, endTime, { from : stoCreator });
      // Adding the offering contract details into the Polymath platform chain data
      let isOfferingFactoryAdded = await compliance.registerOfferingFactory(
        offeringFactory.address,
        {
          from : issuer
        });
      // Propose the Offering contract to a particular Security Token
      let response = await compliance.proposeOfferingFactory(
        securityToken.address,
        offeringFactory.address,
        {
          from : issuer
        });
      // Greping the address of the delegate
      let delegateOfTemp = await securityToken.delegate.call();
      // Update compliance proof hash for the issuance
      let txReturn = await securityToken.updateComplianceProof(
        witnessProof0,
        witnessProof1,
        {
           from : issuer
          });
      convertHex(txReturn.logs[0].args._merkleRoot).should.equal(witnessProof0);
      let issuerBalance = await securityToken.balanceOf(issuer);
      // Opt the Offering contract to distribute the security token
      let success = await securityToken.selectOfferingFactory(
        0,
        {
           from: delegateOfTemp
        });
      success.logs[0].args._owner.should.equal(issuer);
    });

    /////////////////////////////////
    ////// initialiseOffering() Test cases
    /////////////////////////////////

    describe("initialiseOffering() Test Cases",async()=>{
      it("Should not start the offering -- fail msg.sender is not issuer", async()=>{
       try {
         await securityToken.initialiseOffering(startTime, endTime, polyTokenRate, maxPoly, { from : host});
       } catch (error) {
         ensureException(error);
       }
      });

      it("Should active the offering by transferring all ST to the STO contract", async()=>{
        let balance = await securityToken.balanceOf(issuer);
        // After selecting the offering contract Issuer needs to start the offering contract
        // It makes issuer to transfer the ownership of all generated security token to offering contract
        let txReturn = await securityToken.initialiseOffering(startTime, endTime, polyTokenRate, maxPoly, { from : issuer});
        txReturn.logs[0].args._value.toNumber().should.equal(totalSupply);
        // Storing the offering contract imstance to the variable
        offeringContract = await SimpleCappedOffering.at(txReturn.logs[0].args._to);
        assert.isTrue(await securityToken.hasOfferingStarted.call());
      });

      it("Should not start the offering -- fail offering already active", async()=>{
       try {
         await securityToken.initialiseOffering(startTime, endTime, polyTokenRate, maxPoly, { from : issuer});
       } catch (error) {
          ensureException(error);
       }
      });
   });

    //////////////////////////////////
    ////// addToWhiteList() Test Cases
    //////////////////////////////////

    it('addToWhitelist: should add the customer address into the whitelist -- msg.sender == issuer',async()=>{
      // Stampede investor1 as the allowed personality to buy the security token
      let status = await securityToken.addToWhitelist(investor1, { from : issuer });
      status.logs[0].args._shareholder.should.equal(investor1);
    });

    // Test withdrawPoly behaviour before the completion of offering
    it('withdrawPoly: should fail to withdraw because of the current time is less than the endSTO + vesting periond',async()=>{
      let delegateOfTemp = await securityToken.delegate.call();
      try {
          await securityToken.withdrawPoly({ from : delegateOfTemp });
      } catch(error) {
          ensureException(error);
      }
    });

    /////////////////////////////////////////
    ///// updateComplianceProof() Test Cases
    ////////////////////////////////////////

    it('updateComplianceProof:should update the new merkle root',async()=>{
      // Update compliance proof hash for the issuance
      let txReturn = await securityToken.updateComplianceProof(
          witnessProof0,
          witnessProof1,
          {
            from : issuer
          }
        );
        convertHex(txReturn.logs[0].args._merkleRoot).should.equal(witnessProof0);
    });

    it('updateComplianceProof:should not update the new merkle root -- called by unauthorized msg.sender',async()=>{
      try {
      await securityToken.updateComplianceProof(
        witnessProof0,
        witnessProof1,
        {
          from : investor1
        });
      } catch(error) {
        ensureException(error);
    }
    });

});

//////////////////////////////////////
///// Compliance Contract Test Cases
/////////////////////////////////////

describe("Compliance contracts functions", async()=> {
  it("setSTRegsitrar: Should fail to set registrar address because it is already set", async()=>{
    try {
      await compliance.setRegistrarAddress(dummySTRegistrar);
    } catch (error) {
        ensureException(error);
    }
  });

  //////////////////////////////////
  //// proposeTemplate() Test Case
  /////////////////////////////////

  it("proposeTemplate: should successfully propose template", async()=> {
    // Creation of a template to hold complianced or Jurisdictional permissions for trade of Security Token
    let tx = await compliance.createTemplate(
                  "Test",
                  issuerJurisdiction,
                  accredited,
                  provider0,
                  "This is for Test",
                  expires,
                  1000,
                  quorum,
                  vestingPeriod,
                  {
                    from:delegate0
              });
    let templateAdd = tx.logs[0].args._template
    // Accesssing the blueprint using the address of template
    let template2 = await Template.at(templateAdd);

    // Add jusrisdiction and role
    await template2.addJurisdiction(['1','0'], [true,true], { from : delegate0 });
    await template2.addRoles([1,2], { from : delegate0 });

    // Finalizing the template
    await template2.finalizeTemplate({ from : delegate0 });
    let details = await template2.getTemplateDetails.call();
    assert.isTrue(details[1]);

    // Proposing the finalize template to facilitate the trade of particular security token
    let txReturn = await compliance.proposeTemplate(
      securityToken.address,
      templateAdd,
      {
        from : delegate0
      });
    txReturn.logs[0].args._template.should.equal(templateAdd);
  });

  it("proposeTemplate: Should fail in proposing the template -- securityToken is not generated by STR",async()=>{
    // Creation of the false Security Token
    let falseST = await SecurityToken.new(
                        name,
                        ticker,
                        totalSupply,
                        issuer,
                        lockupPeriod,
                        quorum,
                        POLY.address,
                        customers.address,
                        compliance.address,
                        {
                          from : issuer
                    });
    try {
      let txReturn = await compliance.proposeTemplate(
        falseST.address,
        templateAddress,
        {
          from : issuer
        });
    } catch(error) {
        ensureException(error);
    }
  });

  /////////////////////////////////////////
  //// cancelTemplateProposal() Test Cases
  /////////////////////////////////////////

  it("cancelTemplateProposal: Should fails in canceling template proposal -- msg.sender unauthorized", async() =>{
    try {
      let txReturn = await compliance.cancelTemplateProposal(
        securityToken.address,
        1,
        {
          from : delegate1
        });
    } catch(error) {
        ensureException(error);
    }
 });

  it("cancelTemplateProposal: Should successfully cancel template proposal", async() =>{
    // Cancelling the Proposed template
    let txReturn = await compliance.cancelTemplateProposal(
      securityToken.address,
      1,
      {
        from : delegate0
      });
  });

  it("cancelTemplateProposal: Should successfully cancel template proposal --fail because teplate is already choosen", async() =>{
    try {
      let txReturn = await compliance.cancelTemplateProposal(
      securityToken.address,
      0,
      {
        from : delegate0
      });
    } catch(error) {
      ensureException(error);
    }
 });

 //////////////////////////
 /// registerOfferingFactory() Test Cases
 /////////////////////////

  it("registerOfferingFactory: Should fail in adding the new STO factory -- failed because of 0 address", async() =>{
    try {
      let txReturn = await compliance.registerOfferingFactory(0x0);
    } catch(error) {
        ensureException(error);
    }
  });

  it("registerOfferingFactory: Should successfully add the new STO factory", async() =>{
    // Creation of new offering factory to facilitate the distribution of the Security token
    offeringFactory_2 = await SimpleCappedOfferingFactory.new({ from : issuer, gas : 5000000 });
    let txReturn = await compliance.registerOfferingFactory(offeringFactory_2.address);
    txReturn.logs[0].args._offeringFactory.should.equal(offeringFactory_2.address);

  });

  /////////////////////////////////////////
  //// proposeOfferingFactory() Test Cases
  /////////////////////////////////////////

  it("proposeOfferingFactory: Should fail in proposing the contract -- msg.sender is unauthorized", async() =>{
    try {
      let txReturn = await compliance.proposeOfferingFactory(
        securityToken.address,
        offeringFactory_2.address,
        {
          from : investor1
        });
    } catch(error) {
        ensureException(error);
    }
  });

  it("proposeOfferingFactory: Should successfully propose the contract", async() =>{
    // Propose the Offering factory to a particular Security Token
    let txReturn = await compliance.proposeOfferingFactory(
      securityToken.address,
      offeringFactory_2.address,
      {
        from : issuer
      });
      console.log('Proposal Index:',txReturn.logs[2].args._offeringFactoryProposalIndex.toNumber());
      txReturn.logs[2].args._offeringFactory.should.equal(offeringFactory_2.address);
  });

  it("proposeOfferingFactory: Should fail in proposing the STO Factory -- securityToken is not generated by STR",async()=>{
    // Creation of the false Security Token
    let falseST = await SecurityToken.new(
                        name,
                        ticker,
                        totalSupply,
                        issuer,
                        lockupPeriod,
                        quorum,
                        POLY.address,
                        customers.address,
                        compliance.address,
                        {
                          from : issuer
                        });
      try {
        let txReturn = await compliance.proposeOfferingFactory(
          falseST.address,
          offeringFactory_2.address,
          {
            from : issuer
          });
      } catch(error) {
          ensureException(error);
      }
    });

////////////////////////////////////////
/// cancelOfferingFactoryProposal() Test cases
////////////////////////////////////////

it("cancelOfferingFactoryProposal: Should fail in canceling the proposal -- msg.sender unauthorized",async() =>{
    try {
    let txReturn = await compliance.cancelOfferingFactoryProposal(
      securityToken.address,
      1,
      {
        from : investor1
      });
    } catch(error) {
        ensureException(error);
    }
  });

  it("cancelOfferingFactoryProposal: Should successfully cancel the proposal",async() =>{
    // Remove the offering proposal from the list of proposed contracts to a particular Security Token
    let txReturn = await compliance.cancelOfferingFactoryProposal(
      securityToken.address,
      1,
      {
        from : issuer
      });
  });

  it("updateTemplateReputation: should fail to update the template -- msg.sender should be securityToken address",async()=>{
    try {
    let txReturn = await compliance.updateTemplateReputation.call(
      templateAddress,
      0,
      {
        from : delegate0
      });
    } catch(error) {
        ensureException(error);
    }
  });
});

  describe("functions have timejump", async() =>{

    /////////////////////////////////////
    ///// issueSecurityToken() Test Cases
    /////////////////////////////////////

  describe("issueSecurityTokens() Test Cases",async()=>{
    it('issueSecurityTokens: Should successfully allocate the security token to contributor',async()=>{
      // Timejump to make now greater than or equal to the startTime of the sto
      await increaseTime(5010);
      // Provide Approval to securityToken contract for burning POLY of investor1 to buy the Security Token
      await POLY.approve(securityToken.address, 900, { from : investor1 });
      // Buy SecurityToken
      let txReturn = await offeringContract.buy(900, { from : investor1 , gas : 400000 });
      investedAmount = 900;
      txReturn.logs[0].args._ployContribution.toNumber().should.equal(900);
      txReturn.logs[0].args._contributor.should.equal(investor1);
  });

  it('issueSecurityTokens: Should not successfully allocate the security token to contributor -- less allowance',async()=>{
      await POLY.getTokens(1000, investor2, { from : investor2});
      await POLY.approve(securityToken.address, 900, { from : investor2 });
      try {
        let txReturn = await offeringContract.buy(1000, { from : investor2 , gas : 400000 });
      } catch(error) {
        ensureException(error);
      }
  });

  it('issueSecurityTokens: Should not allocate the security token to contributor --fail due to allowance is not provided',
  async()=>{
    try {
      let txReturn = await offeringContract.buy(900, { from : investor1 , gas : 400000 });
    } catch(error) {
      ensureException(error);
    }
  });

  it('issueSecurityTokens: Should not allocate the security token to contributor --fail due to maxpoly limit is reached',
  async()=>{
    // Provide Approval to securityToken contract for burning POLY of investor1 to buy the Security Token
    await POLY.getTokens(100000, investor1, { from : investor1 });
    await POLY.approve(securityToken.address, 100100, { from : investor1 });

    // This function call internally calls issueSecurityTokens  ( 150 extra added because auditor of STO is equal to owner of security Token)
    let txReturn = await offeringContract.buy(maxPoly - (investedAmount + 150), { from : investor1 , gas : 400000 });

    txReturn.logs[0].args._ployContribution.toNumber().should.equal(maxPoly - (investedAmount + 150));
    txReturn.logs[0].args._contributor.should.equal(investor1);

    try {
      let txReturn = await offeringContract.buy(100, { from : investor1 , gas : 400000 });
    } catch(error) {
        ensureException(error);
    }
  });
  });

    /////////////////////////////////////////////////////
    ////////// Test Suite SecurityToken ERC20 functions
    ////////////////////////////////////////////////////

    describe("Test Suite for ERC20 Functions", async()=>{
      it('transfer: ether directly to the token contract -- it will throw', async() => {
        try {
          await web3
              .eth
              .sendTransaction({
                  from: investor1,
                  to: securityToken.address,
                  value: web3.toWei('10', 'Ether')
              });
      } catch (error) {
          ensureException(error);
      }
    });


    it('approve: investor1 should approve 1000 to investor2 & withdraws 200 twice fail in 3 tx when trasferring more than allowance',
    async() => {
      let currentBalance = await securityToken.balanceOf(investor1);
      let status0 = await securityToken.addToWhitelist(investor2,{from: issuer});
      status0.logs[0].args._shareholder.should.equal(investor2);

      let status1 = await securityToken.addToWhitelist(delegate1,{from: issuer});
      status1.logs[0].args._shareholder.should.equal(delegate1);

      await securityToken.approve(investor2, 900, {from: investor1});
      let _allowance1 = await securityToken
          .allowance
          .call(investor1, investor2);
      assert.strictEqual(_allowance1.toNumber(), 900);
      await securityToken.transferFrom(investor1, delegate1, 200, {from: investor2});
      let _balance1 = await securityToken
          .balanceOf
          .call(delegate1);
      assert.strictEqual(_balance1.toNumber(), 200);
      let _allowance2 = await securityToken
          .allowance
          .call(investor1,investor2);
      assert.strictEqual(_allowance2.toNumber(), 700);
      let _balance2 = await securityToken
          .balanceOf
          .call(investor1);
      assert.strictEqual(_balance2.toNumber(), currentBalance - 200);
      await securityToken.transferFrom(investor1, delegate1, 200, {from: investor2});
      let _balance3 = await securityToken
          .balanceOf
          .call(delegate1);
      assert.strictEqual(_balance3.toNumber(), 400);
      let _allowance3 = await securityToken
          .allowance
          .call(investor1, investor2);
      assert.strictEqual(_allowance3.toNumber(), 500);
      let _balance4 = await securityToken
          .balanceOf
          .call(investor1);
      assert.strictEqual(_balance4.toNumber(), currentBalance - 400);

      let txReturn = await securityToken.transferFrom.call(investor1, delegate1, 800, {from: investor2});
      assert.isFalse(txReturn);
    });



    it('Approve max (2^256 - 1)', async() => {
      await securityToken.approve(investor1, '115792089237316195423570985008687907853269984665640564039457584007913129639935', {from: issuer});
      let _allowance = await securityToken.allowance(issuer, investor1);
      let result = _allowance.equals('1.15792089237316195423570985008687907853269984665640564039457584007913129639935e' +
              '+77');
      assert.isTrue(result);
    });
  });


  describe("Test to check the vote to freeze functionality ",async()=>{
    it('voteToFreeze: Should successfully freeze the fee of network participant',async()=>{
        // difference between startTime and endTime
        await increaseTime(2592000);
        let txRetrun = await securityToken.voteToFreeze(issuer, { from : investor1 });;
        txRetrun.logs[0].args._recipient.should.equal(issuer);
        assert.isTrue(txRetrun.logs[0].args._frozen);
      });
    });


    /////////////////////////////////
    ///// withdrawPoly() Test Cases
    ////////////////////////////////

  describe("withdrawPoly() Test Cases with different variations",async()=>{
    it('withdrawPoly: should successfully withdraw poly by delegate',async()=>{
      let delegateOfTemp = await securityToken.delegate.call();
      // Time jump of now + vesting period
      await increaseTime(vestingPeriod);
      let balance = await POLY.balanceOf(securityToken.address);

      let txReturn = await securityToken.withdrawPoly({ from : delegateOfTemp , gas : 3000000 });
      let delegateBalance = await POLY.balanceOf(delegateOfTemp);

      assert.strictEqual(delegateBalance.toNumber(),10000);
  });

  it('withdrawPoly: should not able to successfully withdraw poly by Auditor (STO creator)',async()=>{
    let balance = await POLY.balanceOf(securityToken.address);
    try {
    let success = await securityToken.withdrawPoly({
              from : issuer,
              gas : 3000000
    });
    } catch(error) {
        ensureException(error);
    }
});


  it('withdrawPoly: should fail in withdrawing the poly for direct interaction of customer',async()=>{
    try {
      let success = await securityToken.withdrawPoly({from:investor1});
    } catch(error) {
        ensureException(error);
    }
  });

  it("withdrawPoly: Should transfer all poly to the owner when their is no delegate",async()=>{
    let balanceBefore = await POLY.balanceOf(issuer);

    // Creation of the temporary Security Token
    let tempST = await STRegistrar.createSecurityToken(
      nameSpace,
      "Poly Temp",
      "TPOLY",
      totalSupply,
      0,
      issuer,
      type,
      lockupPeriod,
      quorum,
      {
        from : issuer
      }
  );

  let tempSTAddress = await STRegistrar.getSecurityTokenAddress.call(nameSpace, 'TPOLY');
  let TempSecurityToken = await SecurityToken.at(tempSTAddress);
  let balanceAfter = await POLY.balanceOf(issuer);
  assert.strictEqual( (balanceBefore - balanceAfter), nameSpaceFee);

  let txReturn = await TempSecurityToken.withdrawPoly({ from : issuer});
  let ballast = await POLY.balanceOf(tempSTAddress);
  assert.strictEqual(ballast.toNumber(),0);
  });
});
});

});
