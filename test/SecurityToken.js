import expectRevert from './helpers/expectRevert'

const SecurityToken = artifacts.require('../contracts/SecurityToken.sol')
const POLY = artifacts.require('../contracts/PolyToken.sol')
const Customers = artifacts.require('../contracts/Customers.sol');
const Compliance = artifacts.require('../contracts/Compliance.sol')
const Registrar = artifacts.require('../contracts/SecurityTokenRegistrar.sol')

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
  let owner = accounts[0]
  let spender = accounts[1]
  let to1 = accounts[2]
  let to2 = accounts[3]
  let to3 = accounts[4]
  let attestor0 = accounts[5];
  let attestor1 = accounts[6];
  let customer0 = accounts[7];
  let customer1 = accounts[8];
  let provider0 = accounts[9];
  let provider1 = accounts[0];
  
  //newCustomer() constants
  const jurisdiction0 = "0";
  const jurisdiction1 = "1";
  const customerInvestorRole = 1;
  const customerIssuerRole = 2;
  const witnessProof0 = "ASffjflfgffgf";
  const witnessProof1 = "asfretgtredfgsdfd";

  //verifyCustomer() and approveProvider constants
  const expcurrentTime = new Date().getTime() / 1000; //should get time currently
  const willNotExipre = 1577836800; //Jan 1st 2020, to represent a time that won't fail for testing
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

  let compliance, poly, customers, customer, registrar, security;
  before(async () => {
    compliance = await Compliance.new.apply(this)
    poly = await POLY.new.apply(this)
    customers = await Customers.new.apply(this, [poly.address])
    customer1 = await customers.newCustomer(jurisdiction0, attestor0, customerInvestorRole, witnessProof0)
    customer1 = await customers.newCustomer(jurisdiction0, attestor1, customerIssuerRole, witnessProof1)
    registrar = await Registrar.new.apply(this, [poly.address, customers.address, compliance.address])
    security = await SecurityToken.new.apply(
      this,
      [
        name,
        ticker,
        totalSupply,
        owner,
        templateSHA,
        poly.address,
        customers.address,
        compliance.address,
        registrar.address,
        { from: owner }
      ]
    );
  });

  // This should be put in a helper file; here for now
  function convertTicker(hexx) {
    var hex = hexx.toString();//force conversion
    var str = ''
    for (var i = 0; i < hex.length; i += 2){
        let char = String.fromCharCode(parseInt(hex.substr(i, 2), 16))
        if(char != '\u0000')
          str += char
    }
    return str
  }

  describe('creation of SecurityToken from constructor', async () => {
    it('should be ownable', async () => {
      assert.equal(await security.owner(), owner);
    });

    it('should return correct name after creation', async () => {
      assert.equal(await security.name(), name);
    });

    it('should return correct ticker after creation', async () => {
      let symbol = await security.symbol();
      assert.equal(convertTicker(symbol), ticker);
    });

    it('should return correct decimal points after creation', async () => {
      assert.equal((await security.decimals()).toNumber(), 0);
    });

    it('should return correct total supply after creation', async () => {
      assert.equal((await security.totalSupply()).toNumber(), totalSupply);
    });

    it('should allocate the total supply to the owner after creation', async () => {
      assert.equal((await security.balanceOf(owner)).toNumber(), totalSupply);
    });

    //incomplete tests 

    it('should restrict approval for transfer to any address', async () => {
    });

    it('should restrict transferFrom to any address', async () => {
    });

    it('should allow transferring ownership to another address', async () => {
      //expectRevert(security.approve(owner, spender, 1));
    });

    it('should allow accidentally sent ERC20 tokens to be transferred out of the contract', async () => {

    });

    it('should allow', async () => {

    });

    it('should allow', async () => {

    });
    it('should allow', async () => {

    });
    it('should allow', async () => {

    });
    it('should allow', async () => {

    });
    it('should allow', async () => {

    });
    it('should allow', async () => {

    });
    it('should allow', async () => {

    });
  });

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
    it('', async () => {

    });
    it('', async () => {

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


//don't know about 
//    PolyToken public POLY;
//    Customers PolyCustomers;

//    mapping(address => bool) public investors;

// modifiers
//string public version = '0.1';


// ALL THE IMPORTED CONTRACTS! some have tests , some dont! 
