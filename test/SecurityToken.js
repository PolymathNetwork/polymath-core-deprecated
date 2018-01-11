import should from 'should';

const SecurityToken = artifacts.require('SecurityToken.sol');
const Template = artifacts.require('Template.sol');
const PolyToken = artifacts.require('PolyToken.sol');
const Customers = artifacts.require('Customers.sol');
const Compliance = artifacts.require('Compliance.sol');
const Registrar = artifacts.require('SecurityTokenRegistrar.sol');
const STO = artifacts.require('STOContract.sol'); 
const Utils = require('./helpers/Utils');

// use this function in the time.js -- TODO
async function timeJump(timeToInc) {
  return new Promise((resolve, reject) => {
      web3
          .currentProvider
          .sendAsync({
              jsonrpc: '2.0',
              method: 'evm_increaseTime',
              params: [(timeToInc)] // timeToInc is the time in seconds to increase
          }, function (err, result) {
              if (err) {
                  reject(err);
              }
              resolve(result);
          });
  });
}

contract('SecurityToken', accounts => {

  let allowedAmount = 100; // Spender allowance
  let transferredFunds = 1200; // Funds to be transferred around in tests

  //holders for the 4 functions in Customers.sol
  let newCustomerApplication;
  let verifyCustomerApplication;
  let newKycProviderApplication;
  let approveProviderApplication;

  //accounts
  let issuer = accounts[1];
  let stoCreater = accounts[2];
  let host = accounts[3];
  let owner = accounts[4];
  let attestor0 = accounts[5];
  let attestor1 = accounts[6];
  let customer0 = accounts[7];
  let customer1 = accounts[8];
  let provider0 = accounts[9];
  let provider1 = accounts[0];

  //roles
  const delegateRole = 2;

  //attestor details
  let details0 = 'attestor1details';
  let details1 = 'attestor2details';
  let attestor0Fee = 100;
  let attestor1Fee = 200;

  //newCustomer() constants
  const jurisdiction0 = '0';
  const jurisdiction1 = '1';
  const customerInvestorRole = 1;
  const customerIssuerRole = 2;
  const witnessProof0 = 'ASffjflfgffgf';
  const witnessProof1 = 'asfretgtredfgsdfd';

  //verifyCustomer() and approveProvider constants
  const expcurrentTime = new Date().getTime() / 1000;       //should get time currently
  const willNotExpire = 1577836800;                         //Jan 1st 2020, to represent a time that won't fail for testing
  const willExpire = 1500000000;                            //July 14 2017 will expire
  const startTime = Math.floor(Date.now() / 1000) + 50000;
  const endTime = startTime + 2592000;                      // add 30 days more 

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
  const lockupPeriod = 1541894400;                            // Sunday, 11-Nov-18 00:00:00 UTC
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

  // STO
  let mockStoContract = "0x81399dd18c7985a016eb2bb0a1f6aabf0745d667";
  let stoFee = 150;
 
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
      
      await POLY.getTokens(1000000, provider0, { from : provider0 });
      await POLY.approve(customers.address, 100000, { from : provider0 });

      await customers.newProvider(
        provider0,
        providerName0,
        providerApplication0,
        providerFee0
      ); 
      
      await POLY.getTokens(100000, customer0, { from : customer0 });  
      await POLY.approve(customers.address, 10000, { from : customer0 });

      await customers.verifyCustomer(
          customer0,
          jurisdiction0,
          customerIssuerRole,
          true,
          expcurrentTime + 172800,         // 2 days more than current time
          {
              from:provider0
      });

      await POLY.getTokens(1000000, provider1, { from : provider1 });
      await POLY.approve(customers.address, 100000, { from : provider1 });

      await customers.newProvider(
        provider1,
        providerName1,
        providerApplication1,
        providerFee1
      ); 
      
      await POLY.getTokens(10000, customer1, { from : customer1 });  
      await POLY.approve(customers.address, 10000, { from : customer1 });
      
      await customers.verifyCustomer(
          customer1,
          jurisdiction1,
          customerInvestorRole,
          true,
          expcurrentTime + 172800,         // 2 days more than current time
          {
              from:provider0
      });

      let data = await customers.getCustomer(provider0,customer1);

      await POLY.getTokens(10000, attestor0, { from : attestor0 });  
      await POLY.approve(customers.address, 10000, { from : attestor0 });

      await customers.verifyCustomer(
          attestor0,
          jurisdiction1,
          delegateRole,
          true,
          expcurrentTime + 172800,         // 2 days more than current time
          {
              from:provider0
      });

      await POLY.getTokens(10000, attestor1, { from : attestor1 });  
      await POLY.approve(customers.address, 10000, { from : attestor1 });

      await customers.verifyCustomer(
          attestor1,
          jurisdiction1,
          delegateRole,
          true,
          expcurrentTime + 172800,         // 2 days more than current time
          {
              from:provider0
      });

      await POLY.getTokens(100000, owner, { from : owner });
      await POLY.approve(STRegistrar.address, 100000, { from : owner });
      let allowedToken = await POLY.allowance(owner, STRegistrar.address);
      assert.strictEqual(allowedToken.toNumber(), 100000);

      let st = await STRegistrar.createSecurityToken(
          name,
          ticker,
          totalSupply,
          owner,
          host,
          fee,
          type,
          maxPoly,
          lockupPeriod,
          quorum,
          {
            from : owner
          });  

      STAddress = await STRegistrar.getSecurityTokenAddress.call(ticker);
      securityToken = await SecurityToken.at(STAddress);

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
            from:attestor0
      });
        templateAddress = templateCreated.logs[0].args._template
      
    });
    describe("Functions of securityToken", async() =>{
      it("Constructor verify the parameters",async()=>{
        let symbol = await securityToken.symbol.call();
        assert.strictEqual(symbol.toString(),ticker);
        
        let securityOwner = await securityToken.owner();
        assert.equal(securityOwner,owner);
        
        assert.equal(await securityToken.name(), name);

        assert.equal((await securityToken.decimals()).toNumber(), 0);
        assert.equal((await securityToken.totalSupply()).toNumber(), totalSupply);
        assert.equal((await securityToken.balanceOf(owner)).toNumber(), totalSupply);
      });

    it("selectTemplate: should owner of token can select the template",async()=>{
      let proposeTemplate = await compliance.proposeTemplate(STAddress,templateAddress,{from:attestor0});
      await POLY.getTokens(100000, owner, { from : owner });
      await POLY.transfer(STAddress, 10000, { from : owner }); 
      let template = await securityToken.selectTemplate(tempIndex, { from : owner }); 
      let data = await securityToken.getTokenDetails();
      assert.strictEqual(data[0], templateAddress);
    });

    it("selectOfferingProposal: select the offering proposal for the template",async()=>{
      stoContract = await STO.new(POLY.address,{ from : stoCreater, gas : 5000000 });
      await stoContract.securityTokenOffering(securityToken.address, startTime, endTime); 
      let isSTOAdded = await compliance.setSTO(
        stoContract.address, 
        stoFee, 
        vestingPeriod, 
        quorum, 
        { 
          from : customer0 
        });
      let response = await compliance.proposeOfferingContract(
        securityToken.address, 
        stoContract.address, 
        { 
          from : customer0 
        });
      let delegateOfTemp = await securityToken.delegate.call();
      let txReturn = await securityToken.updateComplianceProof(
        witnessProof0,
        witnessProof1, 
        {
           from : owner 
          });
      Utils.convertHex(txReturn.logs[0].args.merkleRoot).should.equal(witnessProof0);
      let success = await securityToken.selectOfferingProposal(
        0, 
        startTime, 
        endTime,
        {
           from: delegateOfTemp 
        });
      success.logs[0].args._auditor.should.equal(customer0);  
    });

    it('addToWhitelist: should add the customer address into the whitelist',async()=>{
      let template = await Template.at(templateAddress);
      await template.addJurisdiction(['1','0'],[true,true],{from:attestor0});
      await template.addRoles([1,2],{from:attestor0}); 
      let status = await securityToken.addToWhitelist(customer1,{from: provider0});
      status.logs[0].args._shareholder.should.equal(customer1);
    });

    it("addToWhitelist: should fail because kyc is not the msg.sender",async()=>{
      try{
      let status = await securityToken.addToWhitelist(customer1,{from: provider1});
      } catch(error) {
            Utils.ensureException(error);
      }
    });

    it('withdrawPoly: should fail to withdraw because of the current time is less than the endSTO + vesting periond',async()=>{
      let delegateOfTemp = await securityToken.delegate.call();
      try {
          await securityToken.withdrawPoly({from:delegateOfTemp})
      } catch(error) {
          Utils.ensureException(error);
      }
    });

//   //////////////////////////// Test Suite SecurityToken ERC20 functions //////////////////////////////  
    it('transfer: ether directly to the token contract -- it will throw', async() => {
      try {
        await web3
            .eth
            .sendTransaction({
                from: customer1,
                to: securityToken.address,
                value: web3.toWei('10', 'Ether')
            });
    } catch (error) {
         Utils.ensureException(error);
    }
});


it('approve: msg.sender should approve 1000 to accounts[7] & withdraws 200 twice fail in 3 tx when trasferring more than allowance', 
async() => {
    await securityToken.transfer(customer1, 1000, {from: owner});
    let status0 = await securityToken.addToWhitelist(attestor0,{from: provider0});
    status0.logs[0].args._shareholder.should.equal(attestor0);

    let status1 = await securityToken.addToWhitelist(attestor1,{from: provider0});
    status1.logs[0].args._shareholder.should.equal(attestor1);

    await securityToken.approve(attestor0, 1000, {from: customer1});
    let _allowance1 = await securityToken
        .allowance
        .call(customer1, attestor0);
    assert.strictEqual(_allowance1.toNumber(), 1000);
    await securityToken.transferFrom(customer1, attestor1, 200, {from: attestor0});
    let _balance1 = await securityToken
        .balanceOf
        .call(attestor1);
    assert.strictEqual(_balance1.toNumber(), 200);
    let _allowance2 = await securityToken
        .allowance
        .call(customer1,attestor0);
    assert.strictEqual(_allowance2.toNumber(), 800);
    let _balance2 = await securityToken
        .balanceOf
        .call(customer1);
    assert.strictEqual(_balance2.toNumber(), 800);
    await securityToken.transferFrom(customer1, attestor1, 200, {from: attestor0});
    let _balance3 = await securityToken
        .balanceOf
        .call(attestor1);
    assert.strictEqual(_balance3.toNumber(), 400);
    let _allowance3 = await securityToken
        .allowance
        .call(customer1, attestor0);
    assert.strictEqual(_allowance3.toNumber(), 600);
    let _balance4 = await securityToken
        .balanceOf
        .call(customer1);
    assert.strictEqual(_balance4.toNumber(), 600);
   
    let txReturn = await securityToken.transferFrom.call(customer1, attestor1, 800, {from: attestor0});
    assert.isFalse(txReturn);
  });



it('Approve max (2^256 - 1)', async() => {
    await securityToken.approve(customer1, '115792089237316195423570985008687907853269984665640564039457584007913129639935', {from: customer0});
    let _allowance = await securityToken.allowance(customer0, customer1);
    let result = _allowance.equals('1.15792089237316195423570985008687907853269984665640564039457584007913129639935e' +
            '+77');
    assert.isTrue(result);
});

it('approve: should not approve the spnder because it is not whitelisted',async()=>{
     await securityToken.approve(stoCreater, 1000, { from : customer1 });
     let txReturn = await securityToken.allowance(customer1,stoCreater);
     assert.strictEqual(txReturn.toNumber(),0);
});

it('transferFrom: should not transfer because address are not whitelisted',async()=>{
  await securityToken.transferFrom(customer1, stoCreater, 1000,{ from : customer0});
  let txReturn = await securityToken.balanceOf(stoCreater);
  assert.strictEqual(txReturn.toNumber(),0);
});

it('updateComplianceProof:should update the new merkle root',async()=>{
    let txReturn = await securityToken.updateComplianceProof(
      witnessProof0,
      witnessProof1,
      {
        from : owner
      }
    );
    Utils.convertHex(txReturn.logs[0].args.merkleRoot).should.equal(witnessProof0);
});

it('updateComplianceProof:should not update the new merkle root -- called by unauthorized msg.sender',async()=>{
  try {
  await securityToken.updateComplianceProof(
    witnessProof0,
    witnessProof1,
    {
      from : customer1
    });
  } catch(error) {
    Utils.ensureException(error);
}
});

});

describe("Compliance contracts functions",async()=>{
  it("proposeTemplate: should successfully propose template", async()=>{
    let template2 = await compliance.createTemplate(
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
              from:attestor1
            });
    let templateAdd = template2.logs[0].args._template
    let txReturn = await compliance.proposeTemplate(
      securityToken.address,
      templateAdd,
      {
        from : attestor1
      });
      txReturn.logs[0].args._template.should.equal(templateAdd);
  });

  it("cancelTemplateProposal: Should fails in canceling template proposal -- msg.sender unauthorized", async() =>{
    try {
      let txReturn = await compliance.cancelTemplateProposal(
        securityToken.address,
        1,
        {
          from : attestor0
        });
    } catch(error) {
      Utils.ensureException(error);
    }
 });

  it("cancelTemplateProposal: Should successfully cancel template proposal", async() =>{
     let txReturn = await compliance.cancelTemplateProposal(
      securityToken.address,
      1,
      {
        from : attestor1
      });
  });

  it("setSTO:Should fail in adding the new STO contract-- failed because of 0 address", async() =>{
    try {
      let txReturn = await compliance.setSTO(
        0x0,
        fee,
        vestingPeriod,
        quorum,
        {
          from : customer0
        });
    } catch(error) {
      Utils.ensureException(error);
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
          from : customer0
        });
    } catch(error) {
      Utils.ensureException(error);
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
          from : customer0
        });
    } catch(error) {
      Utils.ensureException(error);
    }
  });

  it("setSTO:Should successfully add the new sto contract", async() =>{
      let txReturn = await compliance.setSTO(
        mockStoContract,
        fee,
        vestingPeriod,
        quorum,
        {
          from : customer0
        });
  });

  it("proposeOfferingContract: Should fail in proposing the contract -- msg.sender is unauthorized", async() =>{
    try {
      let txReturn = await compliance.proposeOfferingContract(
        securityToken.address,
        mockStoContract,
        {
          from : customer1
        });
    } catch(error) {
      Utils.ensureException(error);
    }
  });

  it("proposeOfferingContract: Should successfully propose the contract", async() =>{
    let txReturn = await compliance.proposeOfferingContract(
      securityToken.address,
      mockStoContract,
      {
        from : customer0
      });
      txReturn.logs[0].args._offeringContract.should.equal(mockStoContract);
  });

  it("cancelOfferingProposal: Should fail in canceling the proposal -- msg.sender unauthorized",async() =>{
    try {
    let txReturn = await compliance.cancelOfferingProposal(
      securityToken.address,
      1,
      {
        from : customer1
      });
    } catch(error) {
      Utils.ensureException(error);
    }
  });

  it("cancelOfferingProposal: Should successfully cancel the proposal",async() =>{
    let txReturn = await compliance.cancelOfferingProposal(
      securityToken.address,
      1,
      {
        from : customer0
      });
  });

  it("updateTemplateReputation: should fail to update the template -- msg.sender should be securityToken address",async()=>{
    try {
    let txReturn = await compliance.updateTemplateReputation.call(
      templateAddress,
      0,
      {
        from : attestor0
      });
    } catch(error) {
      Utils.ensureException(error);
    }
  });
});

  describe("functions have timejump", async() =>{
    it('issueSecurityTokens: Should successfully allocate the security token to contributor',async()=>{
      await timeJump(50100);  // timejump to make now greater than or equal to the startTime of the sto
      await POLY.approve(securityToken.address, 900, { from : customer1 });
      let txReturn = await stoContract.buySecurityToken(900, { from : customer1 , gas : 400000 });
       txReturn.logs[0].args._ployContribution.toNumber().should.equal(900);
       txReturn.logs[0].args._contributor.should.equal(customer1);
  });
  
  it('issueSecurityTokens: Should successfully allocate the security token to contributor',async()=>{
    await POLY.getTokens(1000, issuer, { from : issuer});
    await POLY.approve(securityToken.address, 900, { from : issuer });
    try {
      let txReturn = await stoContract.buySecurityToken(900, { from : customer1 , gas : 400000 });
    } catch(error) {
      Utils.ensureException(error);
    }
  });
  
  it('issueSecurityTokens: Should not allocate the security token to contributor --fail due to allowance is not provided',
  async()=>{
    try {
      let txReturn = await stoContract.buySecurityToken(900, { from : customer1 , gas : 400000 });
    } catch(error) {
      Utils.ensureException(error);
    } 
  });
  
  it('issueSecurityTokens: Should not allocate the security token to contributor --fail due to maxpoly limit is reached',
  async()=>{
    await POLY.getTokens(100000, customer1, { from : customer1 });
    await POLY.approve(securityToken.address, 100900, { from : customer1 });
    let txReturn = await stoContract.buySecurityToken(99100, { from : customer1 , gas : 400000 });
    txReturn.logs[0].args._ployContribution.toNumber().should.equal(99100);
    txReturn.logs[0].args._contributor.should.equal(customer1);
    try {
      let txReturn = await stoContract.buySecurityToken(900, { from : customer1 , gas : 400000 });
    } catch(error) {
      Utils.ensureException(error);
    } 
  });
    it('voteToFreeze: Should successfully freeze the fee of network participant',async()=>{
      await timeJump(2592000);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
      let txRetrun = await securityToken.voteToFreeze(customer0, { from : customer1 });;
      txRetrun.logs[0].args._recipient.should.equal(customer0);
      assert.isTrue(txRetrun.logs[0].args._frozen);
    });

    it('withdrawPoly: should successfully withdraw poly by delegate',async()=>{
      let delegateOfTemp = await securityToken.delegate.call();

      await timeJump(vestingPeriod);  
      let balance = await POLY.balanceOf(securityToken.address);

      let success = await securityToken.withdrawPoly({ from : delegateOfTemp , gas : 3000000 });
      assert.strictEqual(success.logs[0].args._value.toNumber(),1000);
      let delegateBalance = await POLY.balanceOf(delegateOfTemp);

      assert.strictEqual(delegateBalance.toNumber(),10000);
  });

  it('withdrawPoly: should not able to successfully withdraw poly by Auditor (STO creator)',async()=>{
    let balance = await POLY.balanceOf(securityToken.address);
    try {
    let success = await securityToken.withdrawPoly({ 
              from : customer0,
              gas : 3000000 
    });
    } catch(error) {
      Utils.ensureException(error);
    }
});


  it('withdrawPoly: should fail in withdrawing the poly for direct interaction of customer',async()=>{
    try {
      let success = await securityToken.withdrawPoly({from:customer1});
    } catch(error) {
      Utils.ensureException(error);
    }
  });

  it("withdrawPoly: Should transfer all poly to the owner when their is no delegate",async()=>{
    let balanceBefore = await POLY.balanceOf(owner);
    let tempST = await STRegistrar.createSecurityToken(
      "Poly Temp",
      "TPOLY",
      totalSupply,
      owner,
      host,
      fee,
      type,
      maxPoly,
      lockupPeriod,
      quorum,
      {
        from : owner
      }
  );  

  let tempSTAddress = await STRegistrar.getSecurityTokenAddress.call('TPOLY');
  let TempSecurityToken = await SecurityToken.at(tempSTAddress);
  let balanceAfter = await POLY.balanceOf(owner);
  assert.strictEqual( (balanceBefore - balanceAfter), fee);

  let txReturn = await TempSecurityToken.withdrawPoly();
  let ballast = await POLY.balanceOf(tempSTAddress);
  assert.strictEqual(ballast.toNumber(),0);
  });
});

});
