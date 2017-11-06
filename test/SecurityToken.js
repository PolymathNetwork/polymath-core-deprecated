import expectRevert from './helpers/expectRevert';

const SecurityToken = artifacts.require('../contracts/SecurityToken.sol');

contract('SecurityToken', (accounts) => {

  let security;

  const name = 'Polymath Inc.';
  const ticker = 'POLY';
  const decimals = 1;
  const totalSupply = 1234567890;
  const polyTokenAddress = "0x377bbcae5327695b32a1784e0e13bedc8e078c9c"; //hard coded, from testrpc. need to ensure this is repeatable. truffle 4.0 should be like this. i use "hello" for mneumonic if no truffle 4.0

  let owner = accounts[0];
  let spender = accounts[1];
  let to1 = accounts[2];
  let to2 = accounts[3];
  let to3 = accounts[4];

  let allowedAmount = 100;  // Spender allowance
  let transferredFunds = 1200;  // Funds to be transferred around in tests

  beforeEach(async () => {
    security = await SecurityToken.new(name, ticker, decimals, totalSupply, owner, polyTokenAddress, { from: owner });
  });

  describe('creation of SecurityToken from constructor', async () => {
    it('should be ownable', async () => {
      assert.equal(await security.owner(), owner);
    });

    it('should return correct name after creation', async () => {
      assert.equal(await security.name(), name);
    });

    it('should return correct ticker after creation', async () => {
      assert.equal(await security.symbol(), ticker);
    });

    it('should return correct decimal points after creation', async () => {
      assert.equal(await security.decimals(), decimals);
    });

    it('should return correct total supply after creation', async () => {
      assert.equal(await security.totalSupply(), totalSupply);
    });

    it('should allocate the total supply to the owner after creation', async () => {
      assert.equal((await security.balanceOf(owner)).toNumber(), totalSupply);
    });
    /*This is not implemented yet in SecurityToken.sol. there are no links that i see that prevent this -dk nov 1
    it('should restrict transfer of an unapproved security to all addresses', async () => {
      await expectRevert(security.transfer(owner, spender)); //these were missing await, and failing
      await expectRevert(security.transfer(owner, to1));
      console.log("HIHIIH");
    });*/

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
