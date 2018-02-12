pragma solidity ^0.4.18;

/*
  Polymath compliance protocol is intended to ensure regulatory compliance
  in the jurisdictions that security tokens are being offered in. The compliance
  protocol allows security tokens remain interoperable so that anyone can
  build on top of the Polymath platform and extend it's functionality.
*/
import './SafeMath.sol';
import './interfaces/ICompliance.sol';
import './interfaces/IOfferingFactory.sol';
import './Customers.sol';
import './Template.sol';
import './interfaces/ISecurityToken.sol';
import './interfaces/ISecurityTokenRegistrar.sol';

/**
 * @title Compilance
 * @dev Regulatory details offered by the security token
 */

contract Compliance is ICompliance {

    using SafeMath for uint256;

    string public VERSION = "1";

    ISecurityTokenRegistrar public STRegistrar;

    //Structure used to hold reputation for template and offeringFactories
    struct Reputation {
        uint256 totalRaised;                                             // Total amount raised by issuers that used the template / offeringFactory
        address[] usedBy;                                                // Array of security token addresses that used this particular template / offeringFactory
    }

    mapping(address => Reputation) public templates;                     // Mapping used for storing the template repuation
    mapping(address => address[]) public templateProposals;              // Template proposals for a specific security token

    mapping(address => Reputation) offeringFactories;                    // Mapping used for storing the offering factory reputation
    mapping(address => address[]) public offeringFactoryProposals;       // OfferingFactory proposals for a specific security token

    Customers public PolyCustomers;                                      // Instance of the Compliance contract
    uint256 public constant MINIMUM_VESTING_PERIOD = 60 * 60 * 24 * 100; // 100 Day minimum vesting period for POLY earned

    // Notifications for templates
    event LogTemplateCreated(address indexed _creator, address indexed _template, string _offeringType);
    event LogNewTemplateProposal(address indexed _securityToken, address indexed _template, address indexed _delegate, uint _templateProposalIndex);
    event LogCancelTemplateProposal(address indexed _securityToken, address indexed _template, uint _templateProposalIndex);

    // Notifications for offering factories
    event LogOfferingFactoryRegistered(address indexed _creator, address indexed _offeringFactory, bytes32 _description);
    event LogNewOfferingFactoryProposal(address indexed _securityToken, address indexed _offeringFactory, address indexed _owner, uint _offeringFactoryProposalIndex);
    event LogCancelOfferingFactoryProposal(address indexed _securityToken, address indexed _offeringFactory, uint _offeringFactoryProposalIndex);

    /* @param _polyCustomersAddress The address of the Polymath Customers contract */
    function Compliance(address _polyCustomersAddress) public {
        PolyCustomers = Customers(_polyCustomersAddress);
    }

    /**
     * @dev `setRegistrarAddress` This function set the SecurityTokenRegistrar contract address.
     * @param _STRegistrar It is the `this` reference of STR contract
     * @return bool
     */

    function setRegistrarAddress(address _STRegistrar) public returns (bool) {
        require(_STRegistrar != address(0));
        require(STRegistrar == address(0));
        STRegistrar = ISecurityTokenRegistrar(_STRegistrar);
        return true;
    }

    /**
     * @dev `createTemplate` is a simple function to create a new compliance template
     * @param _offeringType The name of the security being issued
     * @param _issuerJurisdiction The jurisdiction id of the issuer
     * @param _accredited Accreditation status required for investors
     * @param _KYC KYC provider used by the template
     * @param _details Details of the offering requirements
     * @param _expires Timestamp of when the template will expire
     * @param _fee Amount of POLY to use the template (held in escrow until issuance)
     * @param _quorum Minimum percent of shareholders which need to vote to freeze
     * @param _vestingPeriod Length of time to vest funds
     */
    function createTemplate(
        string _offeringType,
        bytes32 _issuerJurisdiction,
        bool _accredited,
        address _KYC,
        bytes32 _details,
        uint256 _expires,
        uint256 _fee,
        uint8 _quorum,
        uint256 _vestingPeriod
    ) public
    {
      require(_KYC != address(0));
      require(_vestingPeriod >= MINIMUM_VESTING_PERIOD);
      require(_quorum > 0 && _quorum <= 100);

      address _template = new Template(
          msg.sender,
          _offeringType,
          _issuerJurisdiction,
          _accredited,
          _KYC,
          _details,
          _expires,
          _fee,
          _quorum,
          _vestingPeriod
      );
      templates[_template] = Reputation({
          totalRaised: 0,
          usedBy: new address[](0)
      });
      LogTemplateCreated(msg.sender, _template, _offeringType);
    }

    /**
     * @dev Propose a bid for a security token issuance
     * @param _securityToken The security token being bid on
     * @param _template The unique template address
     * @return bool success
     */
    function proposeTemplate(
        address _securityToken,
        address _template
    ) public returns (bool success)
    {
        // Verifying that provided _securityToken is generated by securityTokenRegistrar only
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(_securityToken);
        require(securityTokenOwner != address(0));

        // Creating the instance of template to avail the function calling
        ITemplate template = ITemplate(_template);

        //This will fail if template is expired
        var (,finalized) = template.getTemplateDetails();
        var (,,, owner,) = template.getUsageDetails();

        // Require that the caller is the template owner
        // and that the template has been finalized
        require(owner == msg.sender);
        require(finalized);

        //Get a reference of the template contract and add it to the templateProposals array
        templateProposals[_securityToken].push(_template);
        LogNewTemplateProposal(_securityToken, _template, msg.sender, templateProposals[_securityToken].length - 1);
        return true;
    }

    /**
     * @dev Cancel a Template proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _templateProposalIndex The template proposal array index
     * @return bool success
     */
    function cancelTemplateProposal(
        address _securityToken,
        uint256 _templateProposalIndex
    ) public returns (bool success)
    {
        address proposedTemplate = templateProposals[_securityToken][_templateProposalIndex];
        ITemplate template = ITemplate(proposedTemplate);
        var (,,, owner,) = template.getUsageDetails();

        require(owner == msg.sender);
        var (chosenTemplate,,,,,) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenTemplate != proposedTemplate);
        templateProposals[_securityToken][_templateProposalIndex] = address(0);
        LogCancelTemplateProposal(_securityToken, proposedTemplate, _templateProposalIndex);

        return true;
    }

    /**
     * @dev Set the STO contract by the issuer.
     * @param _factoryAddress address of the offering factory
     * @return bool success
     */
    function registerOfferingFactory(
      address _factoryAddress
    ) public returns (bool success)
    {
      require(_factoryAddress != address(0));
      IOfferingFactory offeringFactory = IOfferingFactory(_factoryAddress);
      var (, quorum, vestingPeriod, owner, description) = offeringFactory.getUsageDetails();

      //Validate Offering Factory details
      require(quorum > 0 && quorum <= 100);
      require(vestingPeriod >= MINIMUM_VESTING_PERIOD);
      require(owner != address(0));
      // Add the factory in the available list of factory addresses
      offeringFactories[_factoryAddress] = Reputation({
          totalRaised: 0,
          usedBy: new address[](0)
      });
      LogOfferingFactoryRegistered(owner, _factoryAddress, description);
      return true;
    }

    /**
     * @dev Propose a Security Token Offering Factory for an issuance
     * @param _securityToken The security token being bid on
     * @param _factoryAddress The address of the offering factory
     * @return bool success
     */
    function proposeOfferingFactory(
        address _securityToken,
        address _factoryAddress
    ) public returns (bool success)
    {
        // Verifying that provided _securityToken is generated by securityTokenRegistrar only
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(_securityToken);
        require(securityTokenOwner != address(0));

        IOfferingFactory offeringFactory = IOfferingFactory(_factoryAddress);
        var (,,, owner,) = offeringFactory.getUsageDetails();

        var (,,,,KYC,) = ISecurityToken(_securityToken).getTokenDetails();
        var (,,, expires) = PolyCustomers.getCustomer(KYC, owner);

        require(owner == msg.sender);
        require(expires > now);
        offeringFactoryProposals[_securityToken].push(_factoryAddress);
        LogNewOfferingFactoryProposal(_securityToken, _factoryAddress, owner, offeringFactoryProposals[_securityToken].length - 1);
        return true;
    }

    /**
     * @dev Cancel a STO factory proposal if the bid hasn't been accepted
     * @param _securityToken The security token being bid on
     * @param _offeringFactoryProposalIndex The offeringFactory proposal array index
     * @return bool success
     */
    function cancelOfferingFactoryProposal(
        address _securityToken,
        uint256 _offeringFactoryProposalIndex
    ) public returns (bool success)
    {
        address proposedOfferingFactory = offeringFactoryProposals[_securityToken][_offeringFactoryProposalIndex];
        IOfferingFactory offeringFactory = IOfferingFactory(proposedOfferingFactory);
        var (,,, owner,) = offeringFactory.getUsageDetails();

        require(owner == msg.sender);
        var (,,,,,chosenOfferingFactory) = ISecurityToken(_securityToken).getTokenDetails();
        require(chosenOfferingFactory != proposedOfferingFactory);
        offeringFactoryProposals[_securityToken][_offeringFactoryProposalIndex] = address(0);

        LogCancelOfferingFactoryProposal(_securityToken, proposedOfferingFactory, _offeringFactoryProposalIndex);
        return true;
    }

    /**
     * @dev `updateTemplateReputation` is a constant function that updates the
       history of a security token template usage to keep track of previous uses
     * @param _template The unique template id
     * @param _polyRaised The amount of poly raised
     */
    function updateTemplateReputation(address _template, uint256 _polyRaised) external returns (bool success) {
        //Check that the caller is a security token
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(msg.sender);
        require(securityTokenOwner != address(0));
        //If it is, then update reputation
        templates[_template].usedBy.push(msg.sender);
        templates[_template].totalRaised = templates[_template].totalRaised.add(_polyRaised);
        return true;
    }

    /**
     * @dev `updateOfferingReputation` is a constant function that updates the
       history of a security token offeringFactory contract to keep track of previous uses
     * @param _offeringFactory The address of the offering factory
     * @param _polyRaised The amount of poly raised
     */
    function updateOfferingFactoryReputation(address _offeringFactory, uint256 _polyRaised) external returns (bool success) {
        //Check that the caller is a security token
        var (,, securityTokenOwner,) = STRegistrar.getSecurityTokenData(msg.sender);
        require(securityTokenOwner != address(0));
        //If it is, then update reputation
        offeringFactories[_offeringFactory].usedBy.push(msg.sender);
        offeringFactories[_offeringFactory].totalRaised = offeringFactories[_offeringFactory].totalRaised.add(_polyRaised);
        return true;
    }

    /**
     * @dev Get template details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _templateIndex The array index of the template being checked
     * @return Template struct
     */
    function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
        address _template
    ){
        return templateProposals[_securityTokenAddress][_templateIndex];
    }

    /**
     * @dev Get an array containing the address of all template proposals for a given ST
     * @param _securityTokenAddress The security token ethereum address
     * @return Template proposals array
     */
    function getAllTemplateProposals(address _securityTokenAddress) view public returns (address[]){
        return templateProposals[_securityTokenAddress];
    }

    /**
     * @dev Get security token offering smart contract details by the proposal index
     * @param _securityTokenAddress The security token ethereum address
     * @param _offeringFactoryProposalIndex The array index of the STO contract being checked
     * @return Contract struct
     */
    function getOfferingFactoryByProposal(address _securityTokenAddress, uint8 _offeringFactoryProposalIndex) view public returns (
        address _offeringFactoryAddress
    ){
        return offeringFactoryProposals[_securityTokenAddress][_offeringFactoryProposalIndex];
    }

    /**
     * @dev Get an array containing the address of all offering proposals for a given ST
     * @param _securityTokenAddress The security token ethereum address
     * @return Offering proposals array
     */
    function getAllOfferingFactoryProposals(address _securityTokenAddress) view public returns (address[]) {
        return offeringFactoryProposals[_securityTokenAddress];
    }

}
