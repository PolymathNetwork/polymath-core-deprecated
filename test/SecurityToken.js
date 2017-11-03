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






    /* I BELIEVE ALL TESTS BELOW ARE OLD - dk nov 1
    
    
      describe('activation', async () => {
        
        it('should update balances correctly after minting', async () => {
          
          assert.equal((await security.balanceOf(owner)).toNumber(), totalSupply);
    
          await security.mint(to1, transferredFunds);
    
          // Checking owner balance stays on 0 since minting happens for
          // other accounts.
          assert.equal((await security.balanceOf(owner)).toNumber(), 0);
          assert.equal((await security.balanceOf(to1)).toNumber(), transferredFunds);
    
          await security.mint(to2, transferredFunds);
          assert.equal((await security.balanceOf(to2)).toNumber(), transferredFunds);
    
          await security.mint(to3, transferredFunds);
          assert.equal((await security.balanceOf(to3)).toNumber(), transferredFunds);
    
          assert.equal((await security.balanceOf(owner)).toNumber(), 0);
        });
    
        it('should update totalSupply correctly after minting', async () => {
          assert.equal((await security.totalSupply()).toNumber(), 0);
    
          await security.mint(to1, transferredFunds);
          assert.equal((await security.totalSupply()).toNumber(), transferredFunds);
    
          await security.mint(to1, transferredFunds);
          assert.equal((await security.totalSupply()).toNumber(), transferredFunds * 2);
    
          await security.mint(to2, transferredFunds);
          assert.equal((await security.totalSupply()).toNumber(), transferredFunds * 3);
        });
    
        it('should end minting', async () => {
          await security.endMinting();
          assert.isFalse(await security.isMinting());
        });
    
        it('should allow to end minting more than once', async () => {
          await security.endMinting();
          await security.endMinting();
          await security.endMinting();
        });
    
        it('should not allow to mint after minting has ended', async () => {
          await security.endMinting();
          await expectRevert(security.mint(to1, transferredFunds));
        });
    
        it('should not allow approve() before minting has ended', async () => {
          await expectRevert(security.approve(spender, allowedAmount));
        });
    
        it('should allow approve() after minting has ended', async () => {
          await security.endMinting();
          await security.approve(spender, allowedAmount);
        });
    
        it('should not allow transfer() before minting has ended', async () => {
          await expectRevert(security.transfer(spender, allowedAmount));
        });
    
        it('should allow transfer() after minting has ended', async () => {
          await security.mint(owner, transferredFunds);
          await security.endMinting();
          await security.transfer(to1, transferredFunds);
        });
    
        it('should not allow transferFrom() before minting has ended', async () => {
          await expectRevert(security.transferFrom(owner, to1, allowedAmount, {from: spender}));
        });
    
        it('should allow transferFrom() after minting has ended', async () => {
          await security.mint(owner, transferredFunds);
          await security.endMinting();
          await security.approve(spender, allowedAmount);
          await security.transferFrom(owner, to1, allowedAmount, {from: spender});
        });
      });
    
      describe('approval', async () => {
        it('should log mint event after minting', async () => {
          let result = await security.mint(to1, transferredFunds);
    
          assert.lengthOf(result.logs, 1);
          let event = result.logs[0];
          assert.equal(event.event, 'Transfer');
          assert.equal(event.args.from, 0);
          assert.equal(event.args.to, to1);
          assert.equal(Number(event.args.value), transferredFunds);
        });
    
        it('should log minting ended event after minting has ended', async () => {
          let result = await security.endMinting();
    
          assert.lengthOf(result.logs, 1);
          assert.equal(result.logs[0].event, 'MintingEnded');
    
                // Additional calls should not emit events.
          result = await security.endMinting();
          assert.equal(result.logs.length, 0);
          result = await security.endMinting();
          assert.equal(result.logs.length, 0);
        });
      });
    */
  });

  //owner like functions
  describe("compliance templates. function proposeComplianceTemplate", async () => {
    //setDelegate inside here too, and updateComplianceProof 

    //struct ComplianceTemplate
    //mapping complianceTemplateProposals

    //event LogComplianceTemplateProposal
    //event LogNewComplianceProof
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

});


//don't know about 
//    PolyToken public POLY;
//    Customers PolyCustomers;

//    mapping(address => bool) public investors;

// modifiers
//string public version = '0.1';


// ALL THE IMPORTED CONTRACTS! some have tests , some dont! 
