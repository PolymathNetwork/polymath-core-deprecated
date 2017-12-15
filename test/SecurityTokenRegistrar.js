//this thing is essentially coded in full for a quick once over, not perfect but should be 80% i hope - dave nov 3

import expectRevert from './helpers/expectRevert';
const SecurityTokenRegistrar = artifacts.require('./SecurityTokenRegistrar.sol');
const SecurityToken = artifacts.require('../contracts/SecurityToken.sol');
const POLY = artifacts.require('./PolyToken.sol');
const Compliance = artifacts.require('./Compliance.sol');
const Utils = require('./helpers/Utils');

contract('SecurityTokenRegistrar', accounts => {
  //createSecurityToken variables
  const name = 'Polymath Inc.';
  const ticker = 'POLY';
  const decimals = 1;
  const totalSupply = 1234567890;
  const securityType = 5;
  const numberOfSecurityTypes = 8; //8 is chosen for testing, we don't have all security types spec'd out yet
  const createSecurityTokenFee = 10000;
  const polyRaise = 1000000;
  const quorum = 3;
  const lockupPeriod = 1513296000;  //Friday, 15-Dec-17 00:00:00 UTC  for testing only  
  

  //account
  let owner = accounts[0];
  let acct1 = accounts[1];
  let acct2 = accounts[2];
  let issuer2 = accounts[3];
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
      let allowedToken = await polyToken.allowance(issuer1,STRegistrar.address);
      assert.strictEqual(allowedToken.toNumber(),10000);
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
      it('createSecurityToken:should fail when total supply is zero or below than 0', async () => {
        let polyToken = await POLY.new();
        let polyCompliance = await Compliance.new(polyCustomerAddress);
        let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
        let totalSupply = 0;

        await polyToken.getTokens(1000000,{from : issuer1});
        let issuerBalance = await polyToken.balanceOf(issuer1);
        assert.strictEqual(issuerBalance.toNumber(),1000000);
  
        await polyToken.approve(STRegistrar.address,10000,{from:issuer1});
        try{
              await STRegistrar.createSecurityToken(
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
                      })
          } catch(error) {
              Utils.ensureException(error);
          }
      });

      it('createSecurityToken:should fail when total supply is grater than (2^256)-1', async () => {
        let polyToken = await POLY.new();
        let polyCompliance = await Compliance.new(polyCustomerAddress);
        let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
        let totalSupply = 115792089237316195423570985008687907853269984665640564039457584007913129639936;

        await polyToken.getTokens(1000000,{from : issuer1});
        let issuerBalance = await polyToken.balanceOf(issuer1);
        assert.strictEqual(issuerBalance.toNumber(),1000000);
  
        await polyToken.approve(STRegistrar.address,10000,{from:issuer1});
        try{
              await STRegistrar.createSecurityToken(
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
                      })
          } catch(error) {
              Utils.ensureException(error);
          }
      });

      it("createSecurityToken:should fail when ticker name is already exist", async () => {
        let polyToken = await POLY.new();
        let polyCompliance = await Compliance.new(polyCustomerAddress);
        let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
        
        await polyToken.getTokens(1000000,{from : issuer1});
        await polyToken.getTokens(1000000,{from : issuer2});

        let issuerBalance1 = await polyToken.balanceOf(issuer1);
        let issuerBalance2 = await polyToken.balanceOf(issuer2);
        
        assert.strictEqual(issuerBalance1.toNumber(),1000000);
        assert.strictEqual(issuerBalance2.toNumber(),1000000);

        await polyToken.approve(STRegistrar.address,10000,{from:issuer1});
        await polyToken.approve(STRegistrar.address,10000,{from:issuer2});

        let allowedToken = await polyToken.allowance(issuer1,STRegistrar.address);
        assert.strictEqual(allowedToken.toNumber(),10000);

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
        try{
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
                                    from : issuer2
                                  });
            } catch(error){
                Utils.ensureException(error);
            }    
      });

      it('createSecurityToken:should fail when the approved quantity is less than the fee', async () => {
        let polyToken = await POLY.new();
        let polyCompliance = await Compliance.new(polyCustomerAddress);
        let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
        
        await polyToken.getTokens(1000000,{from : issuer1});
        let issuerBalance1 = await polyToken.balanceOf(issuer1);

        await polyToken.approve(STRegistrar.address,1000,{from:issuer1});
        try {
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
        } catch(error) {
            Utils.ensureException(error);
        }
      });

      it("createSecurityToken:should fail when the security registrar haven't approved to spent the poly" , async () => {
        let polyToken = await POLY.new();
        let polyCompliance = await Compliance.new(polyCustomerAddress);
        let STRegistrar = await SecurityTokenRegistrar.new(polyToken.address,polyCustomerAddress,polyCompliance.address);
        
        await polyToken.getTokens(1000000,{from : issuer1});
        let issuerBalance1 = await polyToken.balanceOf(issuer1);

        try {
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
        } catch(error) {
            Utils.ensureException(error);
        }
      });
     });
    });
});
