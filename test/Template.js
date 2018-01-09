
const Template = artifacts.require('Template.sol');
const Utils = require('./helpers/Utils');

contract("Template",(accounts)=>{

    // parameters for Template constructor
    const offeringType = 'Public sale';
    const issuerJurisdiction = 'canada-ca'; 
    const accredited = false;
    const details = 'This is first template';
    const expires = 1602288000;
    const fee = 1000;
    const quorum = 10;
    const vestingPeriod = 8888888;

    // parameters to facilitate the governing of the template function
    const jurisdiction = ['canada-ca','aus-ag','india-dl','barbados-bd'];
    let KYCAddress;
    let owner;

    before(async()=>{
        KYCAddress = accounts[0];
        owner = accounts[1];
    });

    it("Verify the constructor parameter",
    async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        let tempData = await template.getUsageDetails();
        assert.strictEqual(tempData[0].toNumber(), fee);
        assert.strictEqual(tempData[1].toNumber(), quorum);
        assert.strictEqual(tempData[2].toNumber(), vestingPeriod);
        assert.equal(tempData[3], owner);
        assert.equal(tempData[4], KYCAddress);
    });

    it("addJuridisction: Should add the array of jurisdiction into the allowedJusrisdiction mapping",
    async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, false, true, true], { from : owner });
    });

    it("addJuridisction: Should fail adding into mapping allowedJurisdiction -- msg.sender is not owner",
    async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        try {
            await template.addJurisdiction(jurisdiction, [true, false, true, true], { from : accounts[8] });
        } catch(error) {
            Utils.ensureException(error);
        }
    });

    it("addJuridisction: Should fail adding into mapping allowedJurisdiction -- length of array differ",
    async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        try {
            await template.addJurisdiction(jurisdiction, [true, false, true], { from : owner });
        } catch(error) {
            Utils.ensureException(error);
        }
    });

    it("addJuridisction: Should fail adding into mapping allowedJurisdiction -- change restricted in finalize template",
    async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, true, true, true], { from : owner });
        await template.finalizeTemplate({ from : owner });
       
        try {
            await template.addJurisdiction(['hong-hk','japan-jp'], [true, false], { from : owner });
        } catch(error) {
            Utils.ensureException(error);
        }
    });

    it("addRoles:Should add the new roles",async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addRoles([1,2,3], { from : owner });
    });
    
    it("addRoles:Should add the new roles",async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        try {
            await template.addRoles([1,2,3], { from : accounts[8] });
        } catch(error) {
            Utils.ensureException(error); 
        }
    });

    it("addRoles:Should add the new roles",async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addRoles([1,2], { from : owner });
        await template.finalizeTemplate({ from : owner });

        try {
            await template.addRoles([3], { from : accounts[8] });
        } catch(error) {
            Utils.ensureException(error); 
        }
    });

    it("updateDetails: Should update the details of the template", async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.updateDetails("This is the second template",{ from : owner });
        let tempDetails = await template.getTemplateDetails();
        assert.strictEqual(Utils.convertHex(tempDetails[0]),"This is the second template");
    });

    it("updateDetails: Should fail in updating the details of the template --details are null ", async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        try {
            await template.updateDetails('',{ from : owner });
        } catch(error) {
            Utils.ensureException(error);
        }
    });

    it("updateDetails: Should fail in updating the details of the template -- msg.sender is not owner ", async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        try {
            await template.updateDetails("This is the second template",{ from : accounts[8] });
        } catch(error) {
            Utils.ensureException(error);
        }
    });

    it("finalizetemplate: Should change the template status to finalize", async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.finalizeTemplate({ from : owner });
    });

    it("finalizetemplate: Should change the template status to finalize", async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        try {
            await template.finalizeTemplate({ from : accounts[8] });
        } catch(error) {
            Utils.ensureException(error);
        }
    });

    it('checkTemplateRequirements: Should met the requirements of template', async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, true, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        await template.checkTemplateRequirements(issuerJurisdiction, accredited, 1);
    });

    it('checkTemplateRequirements: Should fail in meeting the requirements of template -- jurisdiction is false', async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [false, false, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(issuerJurisdiction, accredited, 1);
        } catch(error) {
            Utils.ensureException(error);
        } 
    });

    it('checkTemplateRequirements: Should fail in meeting the requirements of template -- jurisdiction is zero', async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, false, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(0x0, accredited, 1);
         } catch(error) {
             Utils.ensureException(error);
         } 
    });

    it('checkTemplateRequirements: Should fail in meeting the requirements of template -- role is not allowed', async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            accredited,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, false, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(0x0, accredited, 4);
         } catch(error) {
             Utils.ensureException(error);
         } 
    });

    it('checkTemplateRequirements: Should fail in meeting the requirements of template -- accredited true', async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            true,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, true, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(issuerJurisdiction, accredited, 1);
         } catch(error) {
             Utils.ensureException(error);
         } 
    });

    it('checkTemplateRequirements: Should pass in meeting the requirements of template ', async()=>{
        let template = await Template.new(
            owner,
            offeringType,
            issuerJurisdiction,
            true,
            KYCAddress,
            details,
            expires,
            fee,
            quorum,
            vestingPeriod
        );
        await template.addJurisdiction(jurisdiction, [true, true, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        await template.checkTemplateRequirements(issuerJurisdiction, true, 1);
    });



});