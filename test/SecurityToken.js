import increaseTime from './helpers/time';
import should from 'should';

const SecurityToken = artifacts.require('SecurityToken.sol');
const Template = artifacts.require('Template.sol');
const PolyToken = artifacts.require('PolyToken.sol');
const Customers = artifacts.require('Customers.sol');
const Compliance = artifacts.require('Compliance.sol');
const Registrar = artifacts.require('SecurityTokenRegistrar.sol');
const Utils = require('./helpers/Utils');

contract('SecurityToken', accounts => {
  const templateSHA = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  let allowedAmount = 100; // Spender allowance
  let transferredFunds = 1200; // Funds to be transferred around in tests

  //holders for the 4 functions in Customers.sol
  let newCustomerApplication;
  let verifyCustomerApplication;
  let newKycProviderApplication;
  let approveProviderApplication;

  //accounts
  let issuer = accounts[1];
  let templateCreater = accounts[2];
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
  const expcurrentTime = new Date().getTime() / 1000; //should get time currently
  const willNotExpire = 1577836800; //Jan 1st 2020, to represent a time that won't fail for testing
  const willExpire = 1500000000; //July 14 2017 will expire
  const startTime = Math.floor(Date.now() / 1000) + 50000 ;
  const endTime = startTime + 2592000;  // add 30 days more 

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
  const bid1Temp = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
  const bid2Temp = 'cccccccccccccccccccccccccccccccc';
  const bid1Fee = 100;
  const bid2Fee = 200;
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
  let stoContract = 0x81399dd18c7985a016eb2bb0a1f6aabf0745d557;
  let stoFee = 150;
 
let POLY, customers, compliance, STRegistrar, securityToken, STAddress, templateAddress;

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

      await POLY.getTokens(100000, owner, { from : owner });
      await POLY.approve(STRegistrar.address, 1000, { from : owner });
      let allowedToken = await POLY.allowance(owner, STRegistrar.address);
      assert.strictEqual(allowedToken.toNumber(), 1000);

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
      );  

      STAddress = await STRegistrar.getSecurityTokenAddress.call(ticker);
      securityToken = await SecurityToken.at(STAddress);

      let templateCreated = await compliance.createTemplate(
          offeringType,
          issuerJurisdiction,
          accredited,
          provider0,
          details,
          expires,
          fee,
          quorum,
          vestingPeriod,
          {
            from:attestor0
      });
        templateAddress = templateCreated.logs[0].args._template
      
    });

    describe('SecurityToken: Should create the security token successfully',async()=>{
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
      let isSTOAdded = await compliance.setSTO(
        stoContract, 
        stoFee, 
        vestingPeriod, 
        quorum, 
        { 
          from : customer0 
        });
      let response = await compliance.proposeOfferingContract(
        securityToken.address, 
        stoContract, 
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
      await template.addRoles([1],{from:attestor0}); 
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

    // it('withdrawPoly: should successfully withdraw the poly',async()=>{
    //   let delegateOfTemp = await securityToken.delegate.call();

    //   await increaseTime(2592000+vestingPeriod+3000);   // endDate-startdate = 2592000 , more 3000 sec to meet the block.timestamp 

    //   let success = await securityToken.withdrawPoly({from:delegateOfTemp});
    //   assert.isTrue(success.toString());
    //   let delegateBalance = POLY.balanceOf.call(delegateOfTemp);
    //   assert.strictEqual(delegateBalance.toNumber(),10000);
    // });

//     it('withdrawPoly: should successfully withdraw the poly',async()=>{
//       await increaseTime(2592000+vestingPeriod+3000);   // endDate-startdate = 2592000 , more 3000 sec to meet the block.timestamp 
//       try {
//         let success = await securityToken.withdrawPoly({from:customer1});
//       } catch(error) {
//         Ytils.ensureException(error);
//       }
//     });

//   //////////////////////////// Test Suite SecurityToken ERC20 functions //////////////////////////////  
//   describe("all the transfers and other ERC20 protocol functions",async()=>{
//     it('transfer: ether directly to the token contract -- it will throw', async() => {
//       try {
//         await web3
//             .eth
//             .sendTransaction({
//                 from: customer1,
//                 to: securityToken.address,
//                 value: web3.toWei('10', 'Ether')
//             });
//     } catch (error) {
//         return Utils.ensureException(error);
//     }
// });
// });



// it('approve: msg.sender should approve 1000 to accounts[7] & withdraws 200 twice', async() => {
//     await securityToken.transfer(customer1, new BigNumber(1000).times(new BigNumber(10).pow(18)), {from: owner});
//     await securityToken.approve(attestor0, new BigNumber(1000).times(new BigNumber(10).pow(18)), {from: customer1});
//     let _allowance1 = await securityToken
//         .allowance
//         .call(customer1, attestor0);
//     assert.strictEqual(_allowance1.dividedBy(new BigNumber(10).pow(18)).toNumber(), 1000);
//     await securityToken.transferFrom(customer1, attestor1, new BigNumber(200).times(new BigNumber(10).pow(18)), {from: attestor0});
//     let _balance1 = await securityToken
//         .balanceOf
//         .call(attestor1);
//     assert.strictEqual(_balance1.dividedBy(new BigNumber(10).pow(18)).toNumber(), 200);
//     let _allowance2 = await securityToken
//         .allowance
//         .call(customer1,attestor0);
//     assert.strictEqual(_allowance2.dividedBy(new BigNumber(10).pow(18)).toNumber(), 800);
//     let _balance2 = await securityToken
//         .balanceOf
//         .call(customer1);
//     assert.strictEqual(_balance2.dividedBy(new BigNumber(10).pow(18)).toNumber(), 800);
//     await token.transferFrom(customer1, host, new BigNumber(200).times(new BigNumber(10).pow(18)), {from: attestor0});
//     let _balance3 = await securityToken
//         .balanceOf
//         .call(host);
//     assert.strictEqual(_balance3.dividedBy(new BigNumber(10).pow(18)).toNumber(), 200);
//     let _allowance3 = await securityToken
//         .allowance
//         .call(customer1, attestor0);
//     assert.strictEqual(_allowance3.dividedBy(new BigNumber(10).pow(18)).toNumber(), 600);
//     let _balance4 = await securityToken
//         .balanceOf
//         .call(customer1);
//     assert.strictEqual(_balance4.dividedBy(new BigNumber(10).pow(18)).toNumber(), 600);
// });

// it('Approve max (2^256 - 1)', async() => {
//     await securityToken.approve(customer1, '115792089237316195423570985008687907853269984665640564039457584007913129639935', {from: customer0});
//     let _allowance = await securityToken.allowance(customer0, customer1);
//     let result = _allowance.equals('1.15792089237316195423570985008687907853269984665640564039457584007913129639935e' +
//             '+77');
//     assert.isTrue(result);
// });


  // describe('SecurityTokenRegistrar flow', async () => {
  //   it('Polymath should launch the SecurityTokenRegistrar', async () => {
  //     registrar = await Registrar.new.apply(this, [
  //       POLY.address,
  //       customers.address,
  //       compliance.address,
  //     ]);
  //     should.exist(registrar);
  //   });

  //   it('Issuer should get 10000 POLY tokens from the faucet', async () => {
  //     await POLY.getTokens(10000, { from: issuer });
  //     let balance = await POLY.balanceOf(issuer);
  //     balance.toNumber().should.equal(10000);
  //   });

  //   it('Issuer approves transfer of 10000 POLY', async () => {
  //     await POLY.approve(registrar.address, 10000, { from: issuer });
  //     let allowance = await POLY.allowance(issuer, registrar.address);
  //     allowance.toNumber().should.equal(10000);
  //   });

  //   it('Issuer should create a new Security Token', async () => {
  //     let securityCreation = await registrar.createSecurityToken(
  //       name,
  //       ticker,
  //       totalSupply,
  //       issuer,
  //       templateSHA,
  //       1,
  //     );
  //     security = SecurityToken.at(
  //       securityCreation.logs[0].args.securityTokenAddress,
  //     );
  //     security.should.exist;
  //   });
  // });

  // describe('Check that the SecurityToken was created properly', async () => {
  //   it('should be ownable', async () => {
  //     let securityOwner = await security.owner();
  //     securityOwner.should.equal(issuer);
  //   });

  //   it('should return correct name after creation', async () => {
  //     assert.equal(await security.name(), name);
  //   });

  //   it('should return correct ticker after creation', async () => {
  //     let symbol = await security.symbol();
  //     assert.equal(convertHex(symbol), ticker);
  //   });

  //   it('should return correct decimal points after creation', async () => {
  //     assert.equal((await security.decimals()).toNumber(), 0);
  //   });

  //   it('should return correct total supply after creation', async () => {
  //     assert.equal((await security.totalSupply()).toNumber(), totalSupply);
  //   });

  //   it('should allocate the total supply to the owner after creation', async () => {
  //     assert.equal((await security.balanceOf(issuer)).toNumber(), totalSupply);
  //   });
  // });

  // describe('SecurityToken flow', async () => {
  //   it('token should already exist', async () => {
  //     security.should.exist;
  //   });

  //   it('issuer sets KYC provider they wish to use', async () => {
  //     // Note sure how KYC provider is set in the codebase?
  //   });

  //   it('Provider0 should purchase POLY tokens', async () => {
  //     await POLY.getTokens(10000, { from: provider0 });
  //     let balance = await POLY.balanceOf(provider0);
  //     balance.toNumber().should.equal(10000);
  //   });

  //   it('Arovider0 approves transfer of 10000 POLY to customers contract', async () => {
  //     await POLY.approve(customers.address, 10000, { from: provider0 });
  //     let allowance = await POLY.allowance(provider0, customers.address);
  //     allowance.toNumber().should.equal(10000);
  //   });

  //   it('add provider0', async () => {
  //     await customers.newAttestor(
  //       provider0,
  //       'attestor zero',
  //       details0,
  //       attestor0Fee,
  //     );
  //   });

  //   it('Attestor1 should purchase POLY tokens', async () => {
  //     await POLY.getTokens(10000, { from: attestor1 });
  //     let balance = await POLY.balanceOf(attestor1);
  //     balance.toNumber().should.equal(10000);
  //   });

  //   it('Attestor1 approves transfer of 10000 POLY to customers contract', async () => {
  //     await POLY.approve(customers.address, 10000, { from: attestor1 });
  //     let allowance = await POLY.allowance(attestor1, customers.address);
  //     allowance.toNumber().should.equal(10000);
  //   });

  //   it('add attestor1', async () => {
  //     await customers.newAttestor(
  //       attestor1,
  //       'attestor one',
  //       details1,
  //       attestor1Fee,
  //     );
  //   });

  //   it('customer0 should purchase POLY tokens', async () => {
  //     await POLY.getTokens(attestor0Fee, { from: customer0 });
  //     let balance = await POLY.balanceOf(customer0);
  //     balance.toNumber().should.equal(attestor0Fee);
  //   });

  //   it('customer0 approves transfer equal to fee in POLY to attestor', async () => {
  //     await POLY.approve(customers.address, attestor0Fee, { from: customer0 });
  //     let allowance = await POLY.allowance(customer0, customers.address);
  //     allowance.toNumber().should.equal(attestor0Fee);
  //   });

  //   it('attestor0 should verify customer0', async () => {
  //     let txReturn = await customers.verifyCustomer(
  //       customer0,
  //       jurisdiction0,
  //       delegateRole,
  //       true,
  //       witnessProof0,
  //       willNotExpire,
  //       { from: attestor0 },
  //     );
  //     txReturn.logs[0].args.verified.should.equal(true);
  //   });

  //   it('customer1 should purchase POLY tokens', async () => {
  //     await POLY.getTokens(attestor1Fee, { from: customer1 });
  //     let balance = await POLY.balanceOf(customer1);
  //     balance.toNumber().should.equal(attestor1Fee);
  //   });

  //   it('customer1 approves transfer equal to fee in POLY to attestor', async () => {
  //     await POLY.approve(customers.address, attestor1Fee, { from: customer1 });
  //     let allowance = await POLY.allowance(customer1, customers.address);
  //     allowance.toNumber().should.equal(attestor1Fee);
  //   });

  //   it('attestor1 should verify customer1', async () => {
  //     let txReturn = await customers.verifyCustomer(
  //       customer1,
  //       jurisdiction1,
  //       delegateRole,
  //       true,
  //       witnessProof1,
  //       willNotExpire,
  //       { from: attestor1 },
  //     );
  //     txReturn.logs[0].args.verified.should.equal(true);
  //   });

  //   it('Legal Delegate1 makes a bid on issues', async () => {
  //     let success = await security.makeBid(
  //       bid1Temp,
  //       bid1Fee,
  //       willNotExpire,
  //       quorum,
  //       vestingPeriod,
  //       attestor0,
  //       { from: customer0 },
  //     );
  //     success.should.exist;
  //   });

  //   it('Legal Delegate2 makes a bid on issues', async () => {
  //     let success = await security.makeBid(
  //       bid2Temp,
  //       bid2Fee,
  //       expires,
  //       quorum,
  //       vestingPeriod,
  //       attestor1,
  //       { from: customer1 },
  //     );
  //     success.should.exist;
  //   });

  //   it('Issuer picks a specific delegate', async () => {
  //     await POLY.getTokens(bid1Fee, { from: issuer });
  //     await POLY.approve(security.address, bid1Fee, { from: issuer });
  //     let txReturn = await security.setDelegate(customer0, { from: issuer });
  //     txReturn.logs[1].args._delegateAddress.should.equal(customer0);
  //   });

  //   it('Check that the issuer can call updateComplianceProof', async () => {
  //     let txReturn = await security.updateComplianceProof(
  //       witnessProof0,
  //       witnessProof1,
  //       { from: customer0 },
  //     );
  //     convertHex(txReturn.logs[0].args.merkleRoot).should.equal(witnessProof0);
  //   });

  //   it('Check that the delegate can call updateComplianceProof', async () => {
  //     let txReturn = await security.updateComplianceProof(
  //       witnessProof1,
  //       witnessProof0,
  //       { from: issuer },
  //     );
  //     convertHex(txReturn.logs[0].args.merkleRoot).should.equal(witnessProof1);
  //   });

    /*
    it('Make a new Security Token Offering (STO)', async() => {
      sto = await STO.new.apply(this, [security.address, willExpire, willNotExpire])
    })

    it('Register the STO contract', async() => {
      await registrar.newSecurityTokenOfferingContract(sto.address, stoFee)
    })

    it('Make sure that the issuer can setSTOContract', async() =>{
      await POLY.getTokens(stoFee, {from: customer0})
      await POLY.approve(security.address, stoFee, {from: customer0})
      await security.setSTOContract(sto.address, willExpire, willNotExpire, {from: customer0})
    })
    */
 // });

  /*
  describe('Check other stuff', async () =>{
    it('should restrict approval for transfer to any address', async () => {

    });

    it('should restrict transferFrom to any address', async () => {
    });

    it('should allow transferring ownership to another address', async () => {
      //expectRevert(security.approve(owner, spender, 1));
    });

    it('should allow accidentally sent ERC20 tokens to be transferred out of the contract', async () => {

    });

  })

  /*********************Compliance Functions Below**************************************** */
  //owner like functions
  /*describe("function proposeComplianceTemplate", async () => {
    //setDelegate inside here too, and updateComplianceProof

    //struct ComplianceTemplate
    //mapping complianceTemplateProposals

    //event LogComplianceTemplateProposal
    //event LogNewComplianceProof
    //bytes32 public complianceWitness

    it('should allow only approved templates to be proposed', async () => {
      //waiting to go forward, see NOTE.0.1 in SecurityToken.sol
    });
    it('should only allow templates that have not expired', async () => {
      //waiting to go forward, see NOTE.0.1 in SecurityToken.sol
    });
    it('should only allow templates that have not expired', async () => {
      //waiting to go forward, see NOTE.0.1 in SecurityToken.sol
    });

  })

  describe("function updateComplianceWitness", async () => {
    //setDelegate inside here too, and updateComplianceProof

    //struct ComplianceTemplate
    //mapping complianceTemplateProposals

    //event LogComplianceTemplateProposal
    //event LogNewComplianceProof
    //bytes32 public complianceWitness

    it('should allow only owner or delegate to call the function', async () => {

    });

  })

  describe("Legal Delegates. function setDelegate setSTO", async () => {
    //i belive function updateComplianceProof should be in here

    //address public delegate
    //address public STO

    // event LogDelegateSet
    //event LogSecuirtyTokenOffering
  })

  describe("KYC. function setKYC", async () => {


    //address public KYC
    //event LogSetKYC
  })

  describe("ERC20 Tokens function transfer, transferFrom balanceOf, approve allowance", async () => {
    //these probably don't need to be repeated , I imagine they are somewhere else, but they will have to be included

    //string public name;
    //uint8 public decimals;
    //string public symbol;
    //address public owner;
    //uint256 public totalSupply;
    //mapping (address => mapping (address => uint256)) allowed;
    //mapping (address => uint256) balances;


  })

  describe("Tests that will have to be written in the future. Comments for now. Need to wait for Solidity code to get updated", async () => {
    //2.7.5 Ratings Tasks
    //Of coder (only if issuer used this coder and process is compelte or expired)
    //Of legal deelgate (only if issuer used this LD and process is complete or expired)
    //Of compliance template (only if this was compilance template used)
  })
  */
});
