//this thing is essentially coded in full for a quick once over, not perfect but should be 80% i hope - dave nov 3

import expectRevert from './helpers/expectRevert';
const SecurityTokenRegistrar = artifacts.require('./SecurityTokenRegistrar.sol');
const SecurityToken = artifacts.require('../contracts/SecurityToken.sol');
const POLY = artifacts.require('./PolyToken.sol');
const Compliance = artifacts.require('./Compliance.sol');

contract('SecurityTokenRegistrar', accounts => {
  //createSecurityToken variables
  const name = 'Polymath Inc.';
  const ticker = 'POLY';
  const decimals = 1;
  const totalSupply = 1234567890;
  const securityType = 5;
  const numberOfSecurityTypes = 8; //8 is chosen for testing, we don't have all security types spec'd out yet
  const createSecurityTokenFee = 100000;
  const polyRaise = 1000000;
  const quorum = 3;
  const lockupPeriod = 1513296000;  //Friday, 15-Dec-17 00:00:00 UTC  for testing only  

  //polyTokenAddress - hard coded, from testrpc. need to ensure this is repeatable. truffle 4.0 should be like this. i use "hello" for mneumonic if no truffle 4.0
  //ropsten address for polyToken is "0x43b9066bbe465523fb84ed2b832e4aaedb337b65"
  //const polyTokenAddress = '0x377bbcae5327695b32a1784e0e13bedc8e078c9c';
  

  //account
  let owner = accounts[0];
  let acct1 = accounts[1];
  let acct2 = accounts[2];
  let acct3 = accounts[3];
  let issuer1 = accounts[4];
  let polyCustomerAddress = accounts[5];
  let host = accounts[6];

  //newSecurityTokenOfferingcontract variables
  const stoContractAddress = ''; //need to fill this in
  const stoFee = 50000;

  describe('Constructor', async () => {
    it('should have polyTokenAddress updated to contract storage', async () => {
        let polyToken = await POLY.new();
        let polyCompliance = await Compliance.new(polyCustomerAddress);
        let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
        let PTAddress = await STRegistrar.polyTokenAddress.call();
        assert.strictEqual(PTAddress,polyToken.address);
    });
  });

  describe('function createSecurityToken', async () => {
    it('should allow for the creation of a Security Token.', async () => {
      let polyToken = await POLY.new();
      let polyCompliance = await Compliance.new(polyCustomerAddress);
      let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
      
      await polyToken.getTokens(1000000,{from : issuer1});
      let issuerBalance = await polyToken.balanceOf(issuer1);
      assert.strictEqual(issuerBalance.toNumber(),1000000);

      await polyToken.approve(STRegistrar.address,10000,{from:issuer1});

      let ST = await STRegistrar.createSecurityToken(
                                name,
                                ticker,
                                totalSupply,
                                owner,
                                host,
                                createSecurityTokenFee,
                                numberOfSecurityTypes,
                                polyRaise,
                                lockupPeriod,
                                quorum,
                                {
                                  from : issuer1
                                });
      let STAddress = await STRegistrar.getSecurityTokenAddress.call(ticker);
      assert.notEqual(STAddress,0);
      let STData = await STRegistrar.getSecurityTokenData.call(STAddress);
      assert.strictEqual(STData[0].toNumber(),totalSupply);
    });

    describe('Creation of SecurityTokenMetaData Struct is within its proper limitations', async () => {
      it('should confirm decimals is between 0-18', async () => {});
      it('should confirm total supply is between 0 and (2^256)-1', async () => {});
      it(`should confirm security type is one of the approved numbers representing a type. it is between 0 - ${
        numberOfSecurityTypes
      } `, async () => {});
      it('should confirm developer fee is between 0 and (2^256)-1', async () => {});
      it('should limit ticker to being 3 or 4 characters, only A-Z', async () => {});
      it('should limit ticker to being 3 or 4 characters, only A-Z', async () => {});
      it('should limit ticker to being 3 or 4 characters, only A-Z', async () => {});
    });

    it('should increment totalSecurityTokens by 1 every time a new SecurityToken is made', async () => {});
    it('should log the event', async () => {});
    it('should properly update registry of security tokens (securityTokens mapping)', async () => {});
    it('should allow Developer bounty to be transferedFrom the issuers POLY balance into the SecurityTokens contract', async () => {
      //this is not coded in yet. this will be a long test
    });
  });

  //this is developer workflow. it needs to be updated in the https://github.com/PolymathNetwork/Solidity/blob/master/docs/SecurityToken.md file - dk nov 1
  describe('function newSecurityTokenOfferingContract ', async () => {
    it('should allow for the creation of a new STO contract.', async () => {});
    it('should allow only approved Developers to call this function.', async () => {
      //needs to be added into the code - dk nov 1
    });
    describe('Creation of SecurityTokenOfferingContract Struct is within its proper limitations', async () => {
      it('should confirm address is not 0', async () => {});
      it('should confirm the token address has never been used before, no overwriting the struct', async () => {
        //i belive right now the contract address and creator address are mixed up in the real code - dk nov 1
        //also, will need to be added into the code - dk nov 1
      });
      it('should confirm fee submitted is between 0 and (2^256)-1', async () => {});
    });
    it('should log the event', async () => {});
    it('should properly update registry of STO contracts (securityTokenOfferingContracts mapping)', async () => {});
  });

  // function approveSecurityTokenOfferingContract(address _contractAddress, bool _approved, uint256 _fee) onlyOwner {
  describe('function approveSecurityTokenOfferingContract', async () => {
    it('should confirm this function is only callable by owner.', async () => {});
    it('Fee should be 0 and (2^256)-1.', async () => {});
    it('should prevent address 0 or any other address in use to be used as _contractAddress.', async () => {});
    it('If _approved is true, it should update .approved and .fee with _approved and _fee, and Log _contractAddress and true', async () => {});
    it('If _approved is false, delete the STO from mapping securityTokenOfferingContracts and confirm it is removed ', async () => {});
  });
});
