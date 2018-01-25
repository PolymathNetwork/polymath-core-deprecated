import { ensureException, convertHex } from './helpers/utils.js';
const Template = artifacts.require('Template.sol');


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
    const countryJurisdiction = ['canada-ca','aus-au','india-in','barbados-bd'];
    const divisionJurisdiction = ['canada-tn', 'aus-ag', 'india-dl'];
    let KYCAddress;
    let owner;

    before(async()=>{
        KYCAddress = accounts[0];                               // Asigining the KYC address
        owner = accounts[1];
    });

    describe("Constructor",async()=>{
    it("Verify the constructor parameter",async()=>{
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
});

    ////////////////////////////////////
    ////// addJurisdiction() Test Cases
    ////////////////////////////////////

    describe("addJurisdiction() Test Cases",async()=>{
    it("addJuridisction: Should add the array of countryJurisdiction into the allowedJusrisdiction mapping",
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
        await template.addJurisdiction(countryJurisdiction, [true, false, true, true], { from : owner });
    });

    it("addJuridisction: Should add the array of divisionJurisdiction into the allowedDivisionJusrisdiction mapping",
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
        await template.addDivisionJurisdiction(divisionJurisdiction, [true, false, true], { from : owner });
    });

    it("addDivisionJuridisction: Should fail adding into mapping allowedJurisdiction -- msg.sender is not owner",
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
            await template.addJurisdiction(countryJurisdiction, [true, false, true, true], { from : accounts[8] });
        } catch(error) {
            ensureException(error);
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
            await template.addJurisdiction(countryJurisdiction, [true, false, true], { from : owner });
        } catch(error) {
            ensureException(error);
        }
    });

    it("addDivisionJuridisction: Should fail adding into mapping blockedDivisionJurisdictions -- length of array differ",
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
            await template.addDivisionJurisdiction(divisionJurisdiction, [true, false], { from : owner });
        } catch(error) {
            ensureException(error);
        }
    });

    it("addJuridisction: Should fail adding into mapping allowedJurisdiction -- Template status is being finalized",
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
        await template.addJurisdiction(countryJurisdiction, [true, true, true, true], { from : owner });
        await template.finalizeTemplate({ from : owner });

        try {
            await template.addJurisdiction(['hong-hk','japan-jp'], [true, false], { from : owner });
        } catch(error) {
            ensureException(error);
        }
    });
});

    ///////////////////////////////////
    ////// addRoles() Test Cases
    //////////////////////////////////

    describe("addRoles() Test Cases",async()=>{
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

    it("addRoles:Should fail in adding the new roles -- fail because msg.sender is not the owner",async()=>{
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
            ensureException(error);
        }
    });

    it("addRoles:Should fail in adding the new roles -- because template status will change to finalized",async()=>{
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
            ensureException(error);
        }
    });
});

    ////////////////////////////////
    ///// updateDetails() Test Cases
    ////////////////////////////////

    describe("updateDetails() Test Cases",async()=>{
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
        assert.strictEqual(convertHex(tempDetails[0]),"This is the second template");
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
            ensureException(error);
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
            ensureException(error);
        }
    });
});

    ///////////////////////////////////
    ///// finalizeTemplate() test cases
    ///////////////////////////////////

    describe("finalizeTemplate() Test Cases",async()=>{
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

    it("finalizetemplate: Should fail to change the template status to finalize -- Due to msg.sender is not owner ", async()=>{
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
            ensureException(error);
        }
    });
});

    ////////////////////////////////////////////
    ///// checkTemplateRequirements() Test cases
    ////////////////////////////////////////////

    describe("checkTemplateRequirements() Test Cases", async()=>{
    it('checkTemplateRequirements: Should met the requirements of template based on country code', async()=>{
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
        await template.addJurisdiction(countryJurisdiction, [true, true, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        let isverify = await template.checkTemplateRequirements.call(issuerJurisdiction, "NA", accredited, 1);
        assert.isTrue(isverify);
    });

    it('checkTemplateRequirements: Should met the requirements of template based on subdivision code', async()=>{
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
        await template.addJurisdiction(countryJurisdiction, [false, true, true, true], { from : owner });
        await template.addDivisionJurisdiction(divisionJurisdiction, [false, false, false], { from : owner });
        await template.addRoles([1,2], { from : owner });
        let isverify = await template.checkTemplateRequirements.call(issuerJurisdiction, 'canada-tn', accredited, 1);
        assert.isTrue(isverify);
    });

    it('checkTemplateRequirements: Should fail in meeting the requirements of template -- country & subdivision jurisdiction is false', async()=>{
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
        await template.addJurisdiction(countryJurisdiction, [false, false, true, true], { from : owner });
        await template.addDivisionJurisdiction(divisionJurisdiction, [false, false, false], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(issuerJurisdiction, 'canada-tn', accredited, 1);
        } catch(error) {
            ensureException(error);
        }
    });

    it('checkTemplateRequirements: Should fail in meeting the requirements of template -- subdivision jurisdiction is true', async()=>{
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
        await template.addJurisdiction(countryJurisdiction, [false, false, true, true], { from : owner });
        await template.addDivisionJurisdiction(divisionJurisdiction, [true, false, false], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(issuerJurisdiction, 'canada-tn', accredited, 1);
        } catch(error) {
            ensureException(error);
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
        await template.addJurisdiction(countryJurisdiction, [true, false, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(0x0, "NA", accredited, 1);
         } catch(error) {
            ensureException(error);
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
        await template.addJurisdiction(countryJurisdiction, [true, false, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(issuerJurisdiction, issuerJurisdiction, accredited, 4);
         } catch(error) {
            ensureException(error);
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
        await template.addJurisdiction(countryJurisdiction, [true, true, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        try {
            await template.checkTemplateRequirements(issuerJurisdiction, issuerJurisdiction, accredited, 1);
         } catch(error) {
            ensureException(error);
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
        await template.addJurisdiction(countryJurisdiction, [true, true, true, true], { from : owner });
        await template.addRoles([1,2], { from : owner });
        await template.checkTemplateRequirements(issuerJurisdiction, issuerJurisdiction, true, 1);
    });
});


});
