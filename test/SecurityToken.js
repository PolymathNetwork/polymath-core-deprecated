import should from 'should';
import { increaseTime, takeSnapshot, revertToSnapshot } from './helpers/time';
import latestTime from './helpers/latestTime';
import { ensureException, convertHex, duration } from './helpers/utils';

const SecurityToken = artifacts.require('SecurityToken.sol');
const Template = artifacts.require('Template.sol');
const PolyToken = artifacts.require('PolyToken.sol');
const Customers = artifacts.require('Customers.sol');
const Compliance = artifacts.require('Compliance.sol');
const Registrar = artifacts.require('SecurityTokenRegistrar.sol');
const STO = artifacts.require('STOContract.sol');


contract('SecurityToken', accounts => {

  //accounts
  //let issuer = accounts[1];
  let stoCreater = accounts[2];
  let host = accounts[3];
  let issuer = accounts[4];
  let delegate0 = accounts[5];
  let delegate1 = accounts[6];
  let investor2 = accounts[7];
  let investor1 = accounts[8];
  let provider0 = accounts[9];
  let provider1 = accounts[0];

  //roles
  const delegateRole = 2;

  //attestor details
  let details0 = 'delegate1details';
  let details1 = 'attestor2details';
  let delegate0Fee = 100;
  let delegate1Fee = 200;

  //newCustomer() constants
  const jurisdiction0 = '0';
  const jurisdiction1 = '1';
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
  let whiteListedKYC;

  // STO
  let mockStoContract = "0x81399dd18c7985a016eb2bb0a1f6aabf0745d667";
  let stoFee = 150;
  let investedAmount;
  let POLY, customers, compliance, STRegistrar, securityToken;
  let STAddress, templateAddress, stoContract;

    before(async()=>{
      POLY = await PolyToken.new();
      customers = await Customers.new(POLY.address);
      compliance = await Compliance.new(customers.address);
      STRegistrar = await Registrar.new(
        POLY.address,
        customers.address,
        compliance.address
      );

      await customers.newProvider(
        provider0,
        providerName0,
        providerApplication0,
        providerFee0
      );
      // Provide approval to the customer contract to register the issuer (This step is performed by the Polymath wizard)
      await POLY.getTokens(100000, issuer, { from : issuer });
      await POLY.approve(customers.address, 10000, { from : issuer });

      await customers.verifyCustomer(
          issuer,
          jurisdiction0,
          customerIssuerRole,                     // issuer have issuer role = 3
          true,
          willExpires,                            // 2 days more than current time
          {
              from:provider0
      });

      await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1
      );
      // Provide approval to the customer contract to register the investor1 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, investor1, { from : investor1 });
      await POLY.approve(customers.address, 10000, { from : investor1 });

      await customers.verifyCustomer(
          investor1,
          jurisdiction1,
          customerInvestorRole,                           // Having investor role = 1
          true,
          willExpires,                                    // 2 days more than current time
          {
              from:provider0
      });

      // Provide approval to the customer contract to register the investor2 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, investor2, { from : investor2 });
      await POLY.approve(customers.address, 10000, { from : investor2 });

      await customers.verifyCustomer(
          investor2,
          jurisdiction1,
          customerInvestorRole,                           // Having investor role = 1
          true,
          willExpires,                                    // 2 days more than current time
          {
              from:provider0
      });

      // Provide approval to the customer contract to register the delegate0 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, delegate0, { from : delegate0 });
      await POLY.approve(customers.address, 10000, { from : delegate0 });

      await customers.verifyCustomer(
          delegate0,
          jurisdiction1,
          delegateRole,                                   // Delegate role = 2
          true,
          willExpires,                                    // 2 days more than current time
          {
              from:provider0
      });

      // Provide approval to the customer contract to register the delegate1 (This step is performed by the Polymath wizard)
      await POLY.getTokens(10000, delegate1, { from : delegate1 });
      await POLY.approve(customers.address, 10000, { from : delegate1 });

      await customers.verifyCustomer(
          delegate1,
          jurisdiction1,
          delegateRole,                                   // Delegate role = 2
          true,
          willExpires,                                    // 2 days more than current time
          {
              from:provider0
      });

      // Provide approval to the Security Token Registrar contract to create the security token (This step is performed by the Polymath wizard)
      await POLY.getTokens(100000, issuer, { from : issuer });
      await POLY.approve(STRegistrar.address, 100000, { from : issuer });
      let allowedToken = await POLY.allowance(issuer, STRegistrar.address);
      assert.strictEqual(allowedToken.toNumber(), 100000);

      let st = await STRegistrar.createSecurityToken(
          name,
          ticker,
          totalSupply,
          issuer,
          maxPoly,
          host,
          fee,
          type,
          lockupPeriod,
          quorum,
          {
            from : issuer
          });

      // Grep the address of the security token
      STAddress = await STRegistrar.getSecurityTokenAddress.call(ticker);
      securityToken = await SecurityToken.at(STAddress);

      whiteListedKYC = [provider0, provider1];

      let templateCreated = await compliance.createTemplate(
          offeringType,
          issuerJurisdiction,
          accredited,
          whiteListedKYC,
          details,
          expires,
          1000,
          quorum,
          vestingPeriod,
          {
            from:delegate0
      });
        templateAddress = templateCreated.logs[0].args._template

    });
    describe("Functions of securityToken", async() =>{
      it("Constructor verify the parameters",async()=>{
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
        let template = await Template.at(templateAddress);
        try {
          await template.addJurisdiction(['1','0'], [true,true], { from : delegate1 });
        } catch(error) {
          ensureException(error);
        }
      });

      it("addJurisdiction: Should add the Jurisdiction in template",async()=>{
        let template = await Template.at(templateAddress);
        await template.addJurisdiction(['1','0'], [true,true], { from : delegate0 });
      });

      it("addRoles: Should add the roles in alowed roles list -- fail msg.sender is not the owner of template",async()=>{
        let template = await Template.at(templateAddress);
        try {
          await template.addRoles([1,2], { from : delegate1 });
        } catch(error) {
          ensureException(error);
        }
      });

      it("addRoles: Should add the roles in alowed roles list",async()=>{
        let template = await Template.at(templateAddress);
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
        let template = await Template.at(templateAddress);
        try {
          await template.finalizeTemplate({ from : delegate1 });
        } catch(error) {
          ensureException(error);
        }
      });

      it("finalizeTemplate: should finalize the template ", async() =>{
        let template = await Template.at(templateAddress);
        await template.finalizeTemplate({ from : delegate0 });
        let details = await template.getTemplateDetails.call();
        assert.isTrue(details[1]);
      });

      it("proposeTemplate: Should proposed the teplate successfully --fails template is not finalized",async()=>{
          await compliance.proposeTemplate(STAddress, templateAddress, { from : delegate0 });
      });

      it("selectTemplate: should owner of token can select the template",async()=>{
        await POLY.getTokens(100000, issuer, { from : issuer });
        await POLY.transfer(STAddress, 10000, { from : issuer });
        let template = await securityToken.selectTemplate(tempIndex, { from : issuer });

        let data = await securityToken.getTokenDetails();
        assert.strictEqual(data[0], templateAddress);
      });

    it("startOffering: Should not start the offering -- fail STO is not proposed yet", async()=>{
      try {
        await securityToken.startOffering({ from : host});
      } catch (error) {
        ensureException(error);
      }
     });

    it("selectOfferingProposal: select the offering proposal for the template",async()=>{
      stoContract = await STO.new(POLY.address, { from : stoCreater, gas : 5000000 });
      await stoContract.securityTokenOffering(securityToken.address, startTime, endTime);
      let isSTOAdded = await compliance.setSTO(
        stoContract.address,
        stoFee,
        vestingPeriod,
        quorum,
        {
          from : issuer
        });
      let response = await compliance.proposeOfferingContract(
        securityToken.address,
        stoContract.address,
        {
          from : issuer
        });
      let delegateOfTemp = await securityToken.delegate.call();
      let txReturn = await securityToken.updateComplianceProof(
        witnessProof0,
        witnessProof1,
        {
           from : issuer
          });
      convertHex(txReturn.logs[0].args._merkleRoot).should.equal(witnessProof0);

      let issuerBalance = await securityToken.balanceOf(issuer);
      let success = await securityToken.selectOfferingProposal(
        0,
        {
           from: delegateOfTemp
        });
      success.logs[0].args._auditor.should.equal(issuer);
    });

    describe("startOffering() Test Cases",async()=>{
      it("Should not start the offering -- fail msg.sender is not issuer", async()=>{
       try {
         await securityToken.startOffering({ from : host});
       } catch (error) {
         ensureException(error);
       }
      });

      it("Should active the offering by transferring all ST to the STO contract", async()=>{
        let balance = await securityToken.balanceOf(issuer);
        let txReturn = await securityToken.startOffering({ from : issuer});
        txReturn.logs[0].args._value.toNumber().should.equal(totalSupply);
        assert.isTrue(await securityToken.hasOfferingStarted.call());
      });

      it("Should not start the offering -- fail offering already active", async()=>{
       try {
         await securityToken.startOffering({ from : issuer});
       } catch (error) {
          ensureException(error);
       }
      });
   });

    //////////////////////////////////
    ////// addToWhiteList() Test Cases
    //////////////////////////////////

    it('addToWhitelist: should add the customer address into the whitelist -- msg.sender == KYC',async()=>{
      let id = await takeSnapshot();                                  // Taking the snapshot to revert the tx
      let status = await securityToken.addToWhitelist(investor1, { from: provider0});
      status.logs[0].args._shareholder.should.equal(investor1);
      await revertToSnapshot(id);                                     // reverting the snapshot
    });

    it('addToWhitelist: should add the customer address into the whitelist -- msg.sender == issuer',async()=>{
      let status = await securityToken.addToWhitelist(investor1, { from : issuer });
      status.logs[0].args._shareholder.should.equal(investor1);
    });

    it("addToWhitelist: should fail because kyc is not the msg.sender",async()=>{
      try{
      let status = await securityToken.addToWhitelist(investor1, { from : provider1 });
      } catch(error) {
            ensureException(error);
      }
    });

    it('withdrawPoly: should fail to withdraw because of the current time is less than the endSTO + vesting periond',async()=>{
      let delegateOfTemp = await securityToken.delegate.call();
      try {
          await STRegistrar.withdrawFunds(ticker, { from : delegateOfTemp });
      } catch(error) {
          ensureException(error);
      }
    });


    it('updateComplianceProof:should update the new merkle root',async()=>{
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
  it("proposeTemplate: should successfully propose template", async()=> {
    let tx = await compliance.createTemplate(
                  "Test",
                  issuerJurisdiction,
                  accredited,
                  whiteListedKYC,
                  "This is for Test",
                  expires,
                  1000,
                  quorum,
                  vestingPeriod,
                  {
                    from:delegate0
              });
    let templateAdd = tx.logs[0].args._template
    let template2 = await Template.at(templateAdd);
    // add jusrisdiction and role
    await template2.addJurisdiction(['1','0'], [true,true], { from : delegate0 });
    await template2.addRoles([1,2], { from : delegate0 });
    // finalizing the template
    await template2.finalizeTemplate({ from : delegate0 });
    let details = await template2.getTemplateDetails.call();
    assert.isTrue(details[1]);

    let txReturn = await compliance.proposeTemplate(
      securityToken.address,
      templateAdd,
      {
        from : delegate0
      });
    txReturn.logs[0].args._template.should.equal(templateAdd);
  });

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

  it("setSTO:Should fail in adding the new STO contract-- failed because of 0 address", async() =>{
    try {
      let txReturn = await compliance.setSTO(
        0x0,
        fee,
        vestingPeriod,
        quorum,
        {
          from : issuer
        });
    } catch(error) {
        ensureException(error);
    }
  });

  it("setSTO:Should fail in adding the new STO contract-- failed because of quorum is greator than 100", async() =>{
    try {
      let txReturn = await compliance.setSTO(
        mockStoContract,
        fee,
        vestingPeriod,
        101,
        {
          from : issuer
        });
    } catch(error) {
        ensureException(error);
    }
  });

  it("setSTO:Should fail in adding the new STO contract-- failed because of vesting period is less than minimum vesting period", async() =>{
    try {
      let txReturn = await compliance.setSTO(
        mockStoContract,
        fee,
        5555555,
        quorum,
        {
          from : issuer
        });
    } catch(error) {
        ensureException(error);
    }
  });

  it("setSTO:Should successfully add the new sto contract", async() =>{
      let txReturn = await compliance.setSTO(
        mockStoContract,
        fee,
        vestingPeriod,
        quorum,
        {
          from : issuer
        });
  });

  it("proposeOfferingContract: Should fail in proposing the contract -- msg.sender is unauthorized", async() =>{
    try {
      let txReturn = await compliance.proposeOfferingContract(
        securityToken.address,
        mockStoContract,
        {
          from : investor1
        });
    } catch(error) {
        ensureException(error);
    }
  });

  it("proposeOfferingContract: Should successfully propose the contract", async() =>{
    let txReturn = await compliance.proposeOfferingContract(
      securityToken.address,
      mockStoContract,
      {
        from : issuer
      });
      txReturn.logs[0].args._offeringContract.should.equal(mockStoContract);
  });

  it("cancelOfferingProposal: Should fail in canceling the proposal -- msg.sender unauthorized",async() =>{
    try {
    let txReturn = await compliance.cancelOfferingProposal(
      securityToken.address,
      1,
      {
        from : investor1
      });
    } catch(error) {
        ensureException(error);
    }
  });

  it("cancelOfferingProposal: Should successfully cancel the proposal",async() =>{
    let txReturn = await compliance.cancelOfferingProposal(
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
      await increaseTime(5010);                           // timejump to make now greater than or equal to the startTime of the sto
     // Provide Approval to securityToken contract for burning POLY of investor1 to buy the Security Token
      await POLY.approve(securityToken.address, 900, { from : investor1 });
      let txReturn = await stoContract.buySecurityToken(900, { from : investor1 , gas : 400000 });
      investedAmount = 900;
      txReturn.logs[0].args._ployContribution.toNumber().should.equal(900);
      txReturn.logs[0].args._contributor.should.equal(investor1);
  });

  it('issueSecurityTokens: Should not successfully allocate the security token to contributor -- less allowance',async()=>{
      await POLY.getTokens(1000, investor2, { from : investor2});
      await POLY.approve(securityToken.address, 900, { from : investor2 });
      try {
        let txReturn = await stoContract.buySecurityToken(1000, { from : investor2 , gas : 400000 });
      } catch(error) {
        ensureException(error);
      }
  });

  it('issueSecurityTokens: Should not allocate the security token to contributor --fail due to allowance is not provided',
  async()=>{
    try {
      let txReturn = await stoContract.buySecurityToken(900, { from : investor1 , gas : 400000 });
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
    let txReturn = await stoContract.buySecurityToken(maxPoly - (investedAmount + 150), { from : investor1 , gas : 400000 });

    txReturn.logs[0].args._ployContribution.toNumber().should.equal(maxPoly - (investedAmount + 150));
    txReturn.logs[0].args._contributor.should.equal(investor1);

    try {
      let txReturn = await stoContract.buySecurityToken(100, { from : investor1 , gas : 400000 });
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


    it('approve: msg.sender should approve 1000 to accounts[7] & withdraws 200 twice fail in 3 tx when trasferring more than allowance',
    async() => {
      let currentBalance = await securityToken.balanceOf(investor1);
      let status0 = await securityToken.addToWhitelist(investor2,{from: provider0});
      status0.logs[0].args._shareholder.should.equal(investor2);

      let status1 = await securityToken.addToWhitelist(delegate1,{from: provider0});
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
        await increaseTime(2592000);                                // difference between startTime and endTime
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

      let txReturn = await STRegistrar.withdrawFunds(ticker, { from : delegateOfTemp , gas : 3000000 });
      let delegateBalance = await POLY.balanceOf(delegateOfTemp);

      assert.strictEqual(delegateBalance.toNumber(),10000);
  });

  it('withdrawPoly: should not able to successfully withdraw poly by Auditor (STO creator)',async()=>{
    let balance = await POLY.balanceOf(securityToken.address);
    try {
    let success = await STRegistrar.withdrawFunds(ticker, {
              from : issuer,
              gas : 3000000
    });
    } catch(error) {
        ensureException(error);
    }
});


  it('withdrawPoly: should fail in withdrawing the poly for direct interaction of customer',async()=>{
    try {
      let success = await STRegistrar.withdrawFunds(ticker, {from:investor1});
    } catch(error) {
        ensureException(error);
    }
  });

  it("withdrawPoly: Should transfer all poly to the owner when their is no delegate",async()=>{
    let balanceBefore = await POLY.balanceOf(issuer);
    let tempST = await STRegistrar.createSecurityToken(
      "Poly Temp",
      "TPOLY",
      totalSupply,
      issuer,
      maxPoly,
      host,
      fee,
      type,
      lockupPeriod,
      quorum,
      {
        from : issuer
      }
  );

  let tempSTAddress = await STRegistrar.getSecurityTokenAddress.call('TPOLY');
  let TempSecurityToken = await SecurityToken.at(tempSTAddress);
  let balanceAfter = await POLY.balanceOf(issuer);
  assert.strictEqual( (balanceBefore - balanceAfter), fee);

  let txReturn = await STRegistrar.withdrawFunds('TPOLY', { from : issuer});
  let ballast = await POLY.balanceOf(tempSTAddress);
  assert.strictEqual(ballast.toNumber(),0);
  });
});
});

});
