pragma solidity ^0.4.15;

import './Ownable.sol';
import './ERC20.sol';
import './ERC20TokenFaucet.sol';

// TODO: Split into security token registry and security token

contract SecurityToken is ERC20 {

    // ERC20 Fields
    string public version = '0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;

    // Accreditation
    struct Accreditation {
      string country; // i.e. CA: 1, US: 2
      uint8 level; // 1, 2, 3, 4
    }
    mapping(address => Accreditation) public accreditations;

    // Compliance Templates proposed
    struct Template {
      address delegate;
      bytes32 template;
      uint256 fee;
    }
    mapping(address => Template) public templates;

    // Issuance tasks completed
    struct Task {
      address assignedTo;
      uint8 fee;
      bool completed;
    }
    mapping(uint8 => Task) public issuanceProcess;

    // Legal delegate
    address public delegate;

    // Developer address - NOTE: added by dave, I think it is necessary to be here but double check with team **********
    address public developer;

    // Whitelist of investors
    mapping(address => bool) public investors;

    // Issuance template applied
    string public issuanceTemplate;

    // Bounties and Expiry
    uint256 public developerBounty;
    uint256 public legalDelegateBounty;
    uint256 public expiryToSubmitAndClaimBounty;

    //Ropsten POLY Token Contract address
    address public tokenAddressPOLY =  0x0f54D1617eCb696e267db81a1956c24373254785;
    //instance of the polyTokenContract
    ERC20TokenFaucet polyTokenContractRopsten;
    polyTokenContractRopsten = ERC20TokenFaucet(tokenAddressPOLY);


    // Notifications
    event LOG_NewInvestor(address indexed investorAddress, address indexed by);
    event LOG_DelegateSet(address indexed delegateAddress);
    event LOG_TemplateProposal(address delegateAddress, uint256 bid, bytes32 template);
    //notifies devs and legal delegates that a new token has been created
    event LOG_NewSecurityTokenCreatedWithBountySet (address indexed securityTokenAddress, string indexed securityTokenTicker, uint256 developerBounty, uint256 legalDelegateBounty); 


    /// Set default security token parameters
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _decimals Divisibility of the token
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum public key address of the security token owner
    function SecurityToken(string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner) {
      owner = _owner;
      name = _name;
      symbol = _ticker;
      decimals = _decimals;
      totalSupply = _totalSupply;
      balances[_owner] = _totalSupply;
      //delegate = _owner; this will be set by another functipn 
    }

    //do we want to use is Ownable here?
    modifier onlyOwner() {
      require (msg.sender == owner);
      _;
    }

    modifier onlyDelegate() {
      require(delegate == msg.sender);
      _;
    }

    modifier onlyDeveloper() {
      require(developer == msg.sender);
      _;
    }

    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && balances[msg.sender] >= _value && _value > 0) {
        return super.transfer(_to, _value); //super gives access to .transfer in parent contract
      } else {
        return false;
      }
    }

    /// Allows contracts to transfer tokens on behalf of token holders
    /// @param _from Address to transfer tokens from
    /// @param _to Address to send tokens to
    /// @param _value Number of tokens to transfer
    /// @return bool success
    /// TODO: eliminate msg.sender for 0x
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && investors[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        return super.transferFrom(_from, _to, _value);
      } else {
        return false;
      }
    }

    /// Approve transfer of tokens manually
    /// @param _spender Address to approve transfer to
    /// @param _value Amount of tokens to approve for transfer
    /// @return bool success
    function approve(address _spender, uint256 _value) returns (bool success) {
      if (investors[_spender]) {
        return super.approve(_spender, _value);
      } else {
        return false;
      }
    }

    /// Assign a legal delegate to the security token issuance
    /// @param _delegate Address of legal delegate
    /// @return bool success
    function setDelegate(address _delegate) onlyOwner returns (bool success) {
      require(delegate == 0x0);
      delegate = _delegate;
      LOG_DelegateSet(_delegate);
      return true;
    }

    /// Whitelist the chosen investor
    /// @param _address Address of investor to be whitelistened
    /// @return bool success
    function whitelistInvestor(address _address) onlyDelegate returns (bool success) {
      investors[_address] = true;
      LOG_NewInvestor(_address, msg.sender);
      return true;
    }

    /// Allow transfer of any accidentally sent ERC20 tokens to the contract owner
    /// @param _tokenAddress Address of ERC20 token
    /// @param _amount Amount of tokens to send
    /// @return bool success
    function transferAnyERC20Token(address _tokenAddress, uint256 _amount) onlyOwner returns (bool success) {
      return ERC20(_tokenAddress).transfer(owner, _amount);
    }

    // New compliance template proposal
    function proposeIssuanceTemplate(address _delegate, bytes32 _templateId, uint256 _bid) {
      templates[_delegate] = Template(_delegate, _templateId, _bid);
      LOG_TemplateProposal(_delegate, _bid, _templateId);
    }

    /// Apply an approved issuance template to the security token
    /// @param _templateId Issuance template ID
    /// @return bool success
    function setIssuanceTemplate(string _templateId) onlyOwner returns (bool success) {
      issuanceTemplate = _templateId;
      return true;

/*********************************************New code to be Reviewed******************************************************** */

    //need to add in two function calls, add bounty for developers and add bounty for legal delegate. it transfers POLY tokens, so needs to be linked to ropsten deployed POLY
    //need to have a propose bid function so devs and legals can propose what they will do it for 
    //want to only assign delegate once, but build in an expiry so you can reassign 

    //HOW DO I WORK IN THE EXPIRY ????

    //Set the bounties in POLY for dev and legal. The owner of the security token must send POLY to the security token address first, otherwise Bounties can't be set
    function setBounties (uint256 _setBountyDev, uint256 _setBountyLegal, uint256 _setExpiry) onlyOwner returns (bool success) {
      uint256 polyAvailableInSecurityTokenContract = polyTokenContractRopsten.balances(msg.sender);

      //This is needed because we don't want to allow for the bounty to be changed after a delegate is chosen. Otherwise the Owner could change the values on the delegate, and give them a lesser reward or less time
      require(delegate == 0x0);

      if (polyAvailableInSecurityTokenContract == (_setBountyDev + setBountyLegal)){
        developerBounty = _setBountyDev;
        legalDelegateBounty = _setBountyLegal
        setExpiry(_setExpiry);
        LOG_NewSecurityTokenCreatedWithBountySet(this, symbol, developerBounty, legalDelegateBounty)
        return true;

      } else {
        revert()
      }
    }

    //can only be called internally, from the setBounties function 
    function setExpiry (uint256 _expiry) internal returns (bool success) {
      expiryToSubmitAndClaimBounty = now + _expiry;
      return true;


    }

    //the 
    function claimDevBounty () onlyDeveloper returns (bool success) {
      //this seems like a weird way to do this, but i am unsure 
      if(polyTokenContractRopsten.transfer(developer, developerBounty) == true) {
        developerBounty = 0;
      }
      
      

    }

    function claimLegalBounty () onlyDelegate returns (bool success) {
      if(issuanceTemplate != "") { //might need to sha3 this, as string literals dont equal
        legalDelegatebounty = 0;
        polyTokenContractRopsten.transfer(delegate, legalDelegateBounty);
        return true;
    } else
      return false;

}

  function setNewDelegateAfterExpiry (address _delegate, uint256 _newExpiry) onlyOwner returns (bool success) {
    require(now > expiryToSubmitAndClaimBounty);
    delegate = 0x0;
    setBounties
    setExpiry(_newExpiry);
    LOG_DelegateSet(_delegate);
    return true 
  }

//add in the ability for legal delegates to voluntarily recuse themselves 




    /// Assign a legal delegate to the security token issuance
    /// @param _delegate Address of legal delegate
    /// @return bool success
    function setDelegate(address _delegate) onlyOwner returns (bool success) {
      require(delegate == 0x0);
      delegate = _delegate;
      LOG_DelegateSet(_delegate);
      return true;
    }
