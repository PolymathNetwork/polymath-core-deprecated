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

    describe("", async () => {

    })

    describe("", async () => {

    })
    describe("", async () => {

    })
    describe("", async () => {

    })

    describe("Tests that will have to be written in the future. Comments for now. Need to wait for Solidity code to get updated", async () => {

    })


});


//don't know about 
