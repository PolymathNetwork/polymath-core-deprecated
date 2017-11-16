pragma solidity ^0.4.15;

import './SafeMath.sol';
import './interfaces/IERC20.sol';
import './PolyToken.sol';
import './Customers.sol';
import './Compliance.sol';
import './Ownable.sol';
import './SecurityTokenOffering.sol';

contract SecurityToken is IERC20, Ownable {

    using SafeMath for uint256;

    string public version = '0.1';

    // Legal delegate
    address public delegate;

    // Delegate Bids
    struct Bid {
      uint256 fee;
      uint256 expires;
      uint32 quorum;
    }
    mapping(address => Bid) public bids;

    // Template
    bytes32 public template;

    // Proof of process
    bytes32 public complianceProof;

    // STO address
    SecurityTokenOffering public STO;

    // KYC Provider
    address public KYC;

    // Security Token Whitelisted Investors
    mapping(address => bool) public investors;

    // Instance of the POLY token contract
    PolyToken public POLY;

    // Instance of the Compliance contract
    Compliance public PolyCompliance;

    // Allocations
    mapping(address => uint256) allocations;

    // Instance of the Customers contract
    Customers PolyCustomers;

    // Until the securityVestingPeriod has ended disable transfers
    uint256 public securityVestingPeriod;

    // By default bountys vest out after 1 month
    uint256 public bountyVestingPeriod = 2592000;

    // ERC20 Fields
    string public name;
    uint8 public decimals;
    string public symbol;
    address public owner;
    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    // Bounty voting
    struct Vote {
      bool hasVoted;
      bool vote;
    }

		// Values for the start and end time of the STO
    uint256 public issuanceEndTime;
    uint256 public issuanceStartTime;

		// Tally values for Bounty voting
    uint256 public yay;
    uint256 public yayPercent;
    bool public bountyFrozen;
    mapping (address => Vote) votes;
		
		// Variables for issuance status
    mapping (address => uint256) issuanceEndBalances;
		mapping (address => bool) issuancePaidOut;
		uint totalIssuance = 0;

    // Notifications
    event LogDelegateBid(address indexed delegateAddress, uint256 bid);
    event LogDelegateSet(address indexed delegateAddress);
    event LogUpdatedComplianceProof(bytes32 merkleRoot, bytes32 complianceProofHash);
    event LogSetKYCProvider(address indexed kycProvider);
    event LogSetSTOContract(address indexed STOAddress);

    modifier onlyOwner() {
      require (msg.sender == owner);
      _;
    }

    modifier onlyDelegate() {
      require (msg.sender == delegate);
      _;
    }

    modifier onlyOwnerOrDelegate() {
      require (msg.sender == delegate || msg.sender == owner);
      _;
    }

		modifier onlySTO() {
			require (msg.sender == address(STO));
			_;
		}

    modifier onlyInvestor(address _investor) {
      require (investors[_investor] == true);
      _;
    }

    /// Set default security token parameters
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum address of the security token owner
    /// @param _template Hash of the compliance template
    /// @param _polyTokenAddress Ethereum address of the POLY token contract
    /// @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
    /// @param _polyComplianceAddress Ethereum address of the PolyCompliance contract
    /// @param _vestingPeriod Vesting period for bounty funds
    function SecurityToken(
      string _name,
      string _ticker,
      uint256 _totalSupply,
      address _owner,
      bytes32 _template,
      address _polyTokenAddress,
      address _polyCustomersAddress,
      address _polyComplianceAddress,
      uint256 _vestingPeriod
    ) {
      owner = _owner;
      name = _name;
      symbol = _ticker;
      decimals = 0;
      template = _template;
      totalSupply = _totalSupply;
      balances[_owner] = _totalSupply;
      POLY = PolyToken(_polyTokenAddress);
      PolyCustomers = Customers(_polyCustomersAddress);
      PolyCompliance = Compliance(_polyComplianceAddress);
      vestingPeriod = _vestingPeriod;
    }

    /// Make a new bid to be the legal delegate
    /// @param _fee The bounty fee requested to become legal delegate
    /// @param _expires The timestamp the bid expires at
    /// @param _quorum The percentage of initial investors required to freeze bounty funds
    /// @return bool success
    function makeBid(uint256 _fee, uint256 _expires, uint32 _quorum) returns (bool success) {
      // require(PolyCompliance.delegates[msg.sender].details != 0x0);
      require(_expires >= now);
      require(_fee > 0);
      bids[msg.sender] = Bid({fee: _fee, expires: _expires, quorum: _quorum});
      return true;
    }

    /// Accept a Delegate's bid
    /// @param _delegate Legal Delegates public ethereum address
    /// @return bool success
    function setDelegate(address _delegate) onlyOwner returns (bool success) {
      require(_delegate == address(0));
      require(bids[_delegate].expires > now);
      require(POLY.balanceOf(this) >= bids[_delegate].fee);
      delegate = _delegate;
      allocations[_delegate] = bids[_delegate].fee;
      LogDelegateSet(_delegate);
      return true;
    }

    /// Update compliance Proof
    /// @param _newMerkleRoot New merkle root hash of the compliance Proofs
    /// @param _complianceProof Compliance Proof hash
    /// @return bool success
    function updateComplianceProof(bytes32 _newMerkleRoot, bytes32 _complianceProof) onlyOwnerOrDelegate returns (bool success) {
      require(msg.sender == owner || msg.sender == delegate);
      complianceProof = _newMerkleRoot;
      LogUpdatedComplianceProof(_newMerkleRoot, _complianceProof);
      return true;
    }

    /// Set the KYC provider
    /// @param _kycProvider Address of KYC provider
    /// @return bool success
    function setKYCProvider(address _kycProvider) onlyOwner returns (bool success) {
      require(_kycProvider != address(0));
      KYC = _kycProvider;
      LogSetKYCProvider(_kycProvider);
      return true;
    }

    /// Set the STO contract address
    /// @param _securityTokenOfferingAddress Ethereum address of the STO contract
    /// @return bool success
    function setSTOContract(
      address _securityTokenOfferingAddress,
      uint256 _startTime,
      uint256 _endTime
    )
      public
      onlyDelegate
      returns (bool success)
    {
      require(_securityTokenOfferingAddress != address(0));
      require(complianceProof != 0);
      require(delegate != address(0));
      // TODO get the developer address and fee
      // require(POLY.balanceOf(this) >= STO.fee + allocations[_delegate]);
      // allocations[developer] = STO.fee
      STO = SecurityTokenOffering(_securityTokenOfferingAddress, _startTime, _endTime);
      issuanceEndTime = _endTime;
      LogSetSTOContract(_securityTokenOfferingAddress);
      return true;
    }

    /// Add an verified investor to the Security Token whitelist
    /// @param _investorAddress Address of the investor attempting to join ST whitelist
    /// @return bool success
    function addInvestor(address _investorAddress) returns (bool success) {
      require(KYC != address(0));
      require(template != 0);
      var (jurisdiction, accredited) = PolyCustomers.getAttestations(KYC, msg.sender);
      bool requirementsMet = PolyCompliance.checkTemplateRequirements(template, jurisdiction, accredited);
      require(requirementsMet);
      investors[_investorAddress] = true;
      return true;
    }

    /// Allow the bounty to be withdrawn by owner, delegate, and the STO developer at appropriate times
    /// @param _amount Amount of POLY being withdrawn from the bounty
    /// @return bool success
    function withdrawBounty(uint256 _amount) returns (bool success) {
      // @dev this 
			if (delegate == address(0)) {
        return POLY.transfer(owner, _amount);
      } else {
				require(now > issuanceEndTime + bountyVestingPeriod);
        require(bountyFrozen == false);
        require(allocations[msg.sender] >= _amount);
				require(POLY.transfer(msg.sender, _amount));
        allocations[msg.sender] = allocations[msg.sender].sub(_amount);
        return true;
      }
    }

    /// Vote to freeze the compliance bounty fund
    /// @param _freezeVote `true` will vote to freeze, `false` will do nothing.
    function voteToFreeze(bool _freezeVote) returns (bool success)  {
      require(delegate != address(0));
      require(now > issuanceEndTime);
      require(now < issuanceEndTime + bountyVestingPeriod);
      require(votes[msg.sender].hasVoted == false);
      if (_freezeVote) {
        yay = yay + issuanceEndBalances[msg.sender];
        yayPercent = yay.mul(100).div(totalSupply);
        if (yayPercent > bids[delegate].quorum) {
          bountyFrozen = true;
        }
      }
      votes[msg.sender] = Vote({ hasVoted: true, vote: _freezeVote });
      return true;
    }

    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (investors[_to] && balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
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
        uint256 _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

		/// @notice `registerIssuance` is used by the STO to register
		///  value to be paid out at the end of the issuance.
		/// @param _contributor The address of the person whose contributing
		/// @param _amount The amount of ST to pay out.
		function registerIssuance(address _contributor, address _amount)
		public
		onlySTO
		{
			require(issuanceEndTime > now);
			require(totalIssuance.add(_amount) > balanceOf(this));
			totalIssuance = totalIssuance.add(_amount);
			issuanceEndBalances(_contributor) = issuanceEndBalances(_contributor)
				.add(_amount);
		}

		/// @notice `collectIssuance` is used to collect ST tokens
		///  after the issuance period has passed.
		function collectIssuance() public {
			require(issuanceEndTime < now);
			require(issuancePaidOut[msg.sender] == false);
			require(issuanceEndBalances[msg.sender] != 0);
			require(transfer(msg.sender, issuanceEndBalances[msg.sender]);
		}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {
      return balances[_owner];
    }

    /// Approve transfer of tokens manually
    /// @param _spender Address to approve transfer to
    /// @param _value Amount of tokens to approve for transfer
    /// @return bool success
    function approve(address _spender, uint256 _value) returns (bool success) {
      if (investors[_spender]) {
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
          revert();
        }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
      } else {
        return false;
      }
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}
