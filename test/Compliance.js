import expectRevert from './helpers/expectRevert';

const Compliance = artifacts.require('../contracts/Compliance.sol');

contract('Compliance', (accounts) => {

    const complianceAddress = "0xcc1f38392f98443b1d25947be91c595ea4e78210"; //hard coded, from testrpc. need to ensure this is repeatable. truffle 4.0 should be like this. i use "hello" for mneumonic if no truffle 4.0

    let owner = accounts[0];
    let spender = accounts[1];
    let to1 = accounts[2];
    let to2 = accounts[3];
    let to3 = accounts[4];

    describe('function newDelegate', async () => {

        it('should allow', async () => {

        });

        it('should allow', async () => {

        });
    });

    describe("function approveDelegate", async () => {

        it('should allow', async () => {

        });

        it('should allow', async () => {

        });
    })

    describe("function createTemplate", async () => {

        it('should allow', async () => {

        });

        it('should allow', async () => {

        });
    })
    describe("function approveTemplate", async () => {

        it('should allow', async () => {

        });

        it('should allow', async () => {

        });
    })

});


//don't know about 
