import expectRevert from './helpers/expectRevert'
import should from 'should'
const SecurityToken = artifacts.require('../contracts/SecurityToken.sol')
const POLY = artifacts.require('../contracts/PolyToken.sol')
const Customers = artifacts.require('../contracts/Customers.sol');
const Compliance = artifacts.require('../contracts/Compliance.sol')
const Registrar = artifacts.require('../contracts/SecurityTokenRegistrar.sol')
const STO = artifacts.require('../contracts/SecurityTokenOffering.sol')


contract('SecurityToken', (accounts) => {

  const templateSHA  = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

  let allowedAmount = 100;  // Spender allowance
  let transferredFunds = 1200;  // Funds to be transferred around in tests

  //holders for the 4 functions in Customers.sol
  let newCustomerApplication;
  let verifyCustomerApplication;
  let newKycProviderApplication;
  let approveProviderApplication;

  //accounts
  let issuer = accounts[1]
  let to1 = accounts[2]
  let to2 = accounts[3]
  let to3 = accounts[4]
  let attestor0 = accounts[5];
  let attestor1 = accounts[6];
  let customer0 = accounts[7];
  let customer1 = accounts[8];
  let provider0 = accounts[9];
  let provider1 = accounts[0];

  //roles
  const delegateRole = 2

  //attestor details
  let details0 = "attestor1details"
  let details1 = "attestor2details"
  let attestor0Fee = 100
  let attestor1Fee = 200

  //newCustomer() constants
  const jurisdiction0 = "0";
  const jurisdiction1 = "1";
  const customerInvestorRole = 1;
  const customerIssuerRole = 2;
  const witnessProof0 = "ASffjflfgffgf";
  const witnessProof1 = "asfretgtredfgsdfd";

  //verifyCustomer() and approveProvider constants
  const expcurrentTime = new Date().getTime() / 1000; //should get time currently
  const willNotExpire = 1577836800; //Jan 1st 2020, to represent a time that won't fail for testing
  const willExpire = 1500000000; //July 14 2017 will expire

  //newProvider() constants
  const providerName0 = "KYC-Chain"
  const providerName1 = "Uport"
  const providerApplication1 = "0xlfkeGlsdjs"
  const providerApplication2 = "0xlfsvrgeX"

  //SecurityToken variables
  const name = 'Polymath Inc.'
  const ticker = 'POLY'
  const totalSupply = 1234567890  


  //Bid variables
  const bid1Temp  = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  const bid2Temp  = "cccccccccccccccccccccccccccccccc"
  const bid1Fee = 100
  const bid2Fee = 200
  const expires = 1602288000
  const quorum = 10
  const vestingPeriod = 7777777
  
  // STO
  let sto
  let stoFee = 150

  let compliance, poly, customers, customer, registrar, security;
  before(async () => {
    compliance = await Compliance.new.apply(this)
    poly = await POLY.new.apply(this)
    customers = await Customers.new.apply(this, [poly.address])
    let custResult1 = await customers.newCustomer(jurisdiction0, attestor0, customerInvestorRole, witnessProof0, {from: customer0})
    await customers.newCustomer(jurisdiction0, attestor1, customerIssuerRole, witnessProof1, {from: customer1})
  });

  // This should be put in a helper file; here for now
  function convertHex(hexx) {
    var hex = hexx.toString();//force conversion
    var str = ''
    for (var i = 0; i < hex.length; i += 2){
        let char = String.fromCharCode(parseInt(hex.substr(i, 2), 16))
        if(char != '\u0000')
          str += char
    }
    return str
  }


  describe('SecurityTokenRegistrar flow', async () => {
    it('Polymath should launch the SecurityTokenRegistrar', async() => {
      registrar = await Registrar.new.apply(this, [poly.address, customers.address, compliance.address])
      should.exist(registrar)
    })

    it('Issuer should purchase POLY tokens', async () => {
      await poly.getTokens(10000, {from: issuer})
      let balance = await poly.balanceOf(issuer)
      balance.toNumber().should.equal(10000)
    })

    it('Issuer approves transfer of 10000 POLY', async() => {
      await poly.approve(registrar.address, 10000, {from: issuer})
      let allowance = await poly.allowance(issuer, registrar.address)
      allowance.toNumber().should.equal(10000)
    })

    it('Issuer should create a new Security Token', async () => {
      let securityCreation = await registrar.createSecurityToken(
        name,
        ticker,
        totalSupply,
        issuer,
        templateSHA,
        1
      )
      security = SecurityToken.at(securityCreation.logs[0].args.securityTokenAddress)
      security.should.exist
    })
  })

  describe('Check that the SecurityToken was created properly', async () => {
    it('should be ownable', async () => {
      let securityOwner = await security.owner();
      securityOwner.should.equal(issuer)
    });

    it('should return correct name after creation', async () => {
      assert.equal(await security.name(), name);
    });

    it('should return correct ticker after creation', async () => {
      let symbol = await security.symbol();
      assert.equal(convertHex(symbol), ticker);
    });

    it('should return correct decimal points after creation', async () => {
      assert.equal((await security.decimals()).toNumber(), 0);
    });

    it('should return correct total supply after creation', async () => {
      assert.equal((await security.totalSupply()).toNumber(), totalSupply);
    });

    it('should allocate the total supply to the owner after creation', async () => {
      assert.equal((await security.balanceOf(issuer)).toNumber(), totalSupply);
    });
  })

  describe('SecurityToken flow', async () => {
    it('token should already exist', async ()=> {
      security.should.exist
    })
    
    it('issuer sets KYC provider they wish to use', async ()=> {
      // Note sure how KYC provider is set in the codebase?
    })


    it('Attestor0 should purchase POLY tokens', async () => {
      await poly.getTokens(10000, {from: attestor0})
      let balance = await poly.balanceOf(attestor0)
      balance.toNumber().should.equal(10000)
    })

    it('Attestor0 approves transfer of 10000 POLY to customers contract', async() => {
      await poly.approve(customers.address, 10000, {from: attestor0})
      let allowance = await poly.allowance(attestor0, customers.address)
      allowance.toNumber().should.equal(10000)
    })

    it('add attestor0', async() => {
      await customers.newAttestor(attestor0, "attestor zero", details0, attestor0Fee)     
    })
    
    it('Attestor1 should purchase POLY tokens', async () => {
      await poly.getTokens(10000, {from: attestor1})
      let balance = await poly.balanceOf(attestor1)
      balance.toNumber().should.equal(10000)
    })

    it('Attestor1 approves transfer of 10000 POLY to customers contract', async() => {
      await poly.approve(customers.address, 10000, {from: attestor1})
      let allowance = await poly.allowance(attestor1, customers.address)
      allowance.toNumber().should.equal(10000)
    })

    it('add attestor1', async() => {
      await customers.newAttestor(attestor1, "attestor one", details1, attestor1Fee)
    })

    it('customer0 should purchase POLY tokens', async () => {
      await poly.getTokens(attestor0Fee, {from: customer0})
      let balance = await poly.balanceOf(customer0)
      balance.toNumber().should.equal(attestor0Fee)
    })

    it('customer0 approves transfer equal to fee in POLY to attestor', async() => {
      await poly.approve(customers.address, attestor0Fee, {from: customer0})
      let allowance = await poly.allowance(customer0, customers.address)
      allowance.toNumber().should.equal(attestor0Fee)
    })

    it('attestor0 should verify customer0', async() => {
      let txReturn = await customers.verifyCustomer(
        customer0,
        jurisdiction0,
        delegateRole,
        true,
        witnessProof0,
        willNotExpire,
        {from: attestor0}
      )
      txReturn.logs[0].args.verified.should.equal(true)
    })

    it('customer1 should purchase POLY tokens', async () => {
      await poly.getTokens(attestor1Fee, {from: customer1})
      let balance = await poly.balanceOf(customer1)
      balance.toNumber().should.equal(attestor1Fee)
    })

    it('customer1 approves transfer equal to fee in POLY to attestor', async() => {
      await poly.approve(customers.address, attestor1Fee, {from: customer1})
      let allowance = await poly.allowance(customer1, customers.address)
      allowance.toNumber().should.equal(attestor1Fee)
    })

    it('attestor1 should verify customer1', async() => {
      let txReturn = await customers.verifyCustomer(
        customer1,
        jurisdiction1,
        delegateRole,
        true,
        witnessProof1,
        willNotExpire,
        {from: attestor1}
      )
      txReturn.logs[0].args.verified.should.equal(true)
    })

    it('Legal Delegate1 makes a bid on issues', async () => {
      let success = await security.makeBid(
        bid1Temp,
        bid1Fee,
        willNotExpire,
        quorum,
        vestingPeriod,
        attestor0,
        {from: customer0}
      )
      success.should.exist
    })

    it('Legal Delegate2 makes a bid on issues', async () => {
      let success = await security.makeBid(
        bid2Temp,
        bid2Fee,
        expires,
        quorum,
        vestingPeriod,
        attestor1,
        {from: customer1}        
      )
      success.should.exist
    })

    it('Issuer picks a specific delegate', async() => {
      await poly.getTokens(bid1Fee, {from: issuer})
      await poly.approve(security.address, bid1Fee, {from: issuer})
      let txReturn = await security.setDelegate(customer0, {from: issuer})
      txReturn.logs[1].args._delegateAddress.should.equal(customer0)
    })

    it('Check that the issuer can call updateComplianceProof', async() => {
      let txReturn = await security.updateComplianceProof(witnessProof0, witnessProof1, {from: customer0})      
      convertHex(txReturn.logs[0].args.merkleRoot).should.equal(witnessProof0)
    })


    it('Check that the delegate can call updateComplianceProof', async() => {
      let txReturn = await security.updateComplianceProof(witnessProof1, witnessProof0, {from: issuer})      
      convertHex(txReturn.logs[0].args.merkleRoot).should.equal(witnessProof1)
    })

    it('Make a new Security Token Offering (STO)', async() => {
      sto = await STO.new.apply(this, [security.address, willExpire, willNotExpire])       
    })

    it('Register the STO contract', async() => {
      await registrar.newSecurityTokenOfferingContract(sto.address, stoFee)
    })

    it('Make sure that the issuer can setSTOContract', async() =>{
      await poly.getTokens(stoFee, {from: customer0})
      await poly.approve(security.address, stoFee, {from: customer0})
      await security.setSTOContract(sto.address, willExpire, willNotExpire, {from: customer0})
    })

  })

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
  describe("function proposeComplianceTemplate", async () => {
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


});
