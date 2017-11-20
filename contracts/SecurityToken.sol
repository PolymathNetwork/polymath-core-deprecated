pragma solidity ^0.4.15;

import './SafeMath.sol';
import './interfaces/IERC20.sol';
import './Customers.sol';
import './interfaces/ISTRegistrar.sol';
import './interfaces/ICompliance.sol';
import './interfaces/ISTRegistrar.sol';
import './SecurityTokenOffering.sol';

contract SecurityToken is IERC20 {

    using SafeMath for uint256;

    string public version = "0.1";

    // Legal delegate
    address public delegate;

    // Delegate Bids
    struct Bid {
        uint256 fee;
        uint256 expires;
        uint32 quorum;
        uint256 vestingPeriod;
        address attestor;
    }
    mapping(address => Bid) public bids;

    // Template
    bytes32 public template;

    // Proof of process
    bytes32 public complianceProof;

    // STO address
    SecurityTokenOffering public STO;

    // Attestation provider
    address public attestor;

    // Security token shareholders
    mapping(address => bool) public shareholders;

    // Instance of the POLY token contract
    IERC20 public POLY;

    // Instance of the Security Token Registrar interface
    ISTRegistrar public SecurityTokenRegistrar;

    // Instance of the Compliance contract
    ICompliance public PolyCompliance;

    // Instance of the Customers contract
    Customers PolyCustomers;

    // ERC20 Fields
    string public name;
    uint8 public decimals;
    bytes8 public symbol;
    address public owner;
    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    // Bounty allocations
    mapping(address => uint256) allocations;

    // Bounty voting
    struct Vote {
        bool hasVoted;
        bool vote;
    }

		// Values for the start and end time of the STO
    uint256 public issuanceStartTime;
    uint256 public issuanceEndTime;

    // The period which ST holders can vote to freeze the bounty
    uint256 public bountyVestingPeriod;

		// Tally values for Bounty voting
    uint256 public yay;
    uint256 public yayPercent;
    bool public freezeBounty;
    mapping (address => Vote) votes;

		// Variables for issuance status
    mapping (address => uint256) issuanceEndBalances;
		mapping (address => bool) issuancePaidOut;
		uint securityTokensIssued = 0;

    // Notifications
    event LogDelegateBid(address indexed _delegateAddress, uint256 _bid);
    event LogDelegateSet(address indexed _delegateAddress);
    event LogUpdatedComplianceProof(bytes32 merkleRoot, bytes32 _complianceProofHash);
    event LogSetAttestor(address indexed _attestor);
    event LogSetSTOContract(address indexed _STOAddress);

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

    modifier onlyShareholder(address _shareholder) {
        require (shareholders[_shareholder] == true);
        _;
    }

    /// Set default security token parameters
    /// @param _name Name of the security token
    /// @param _ticker Ticker name of the security
    /// @param _totalSupply Total amount of tokens being created
    /// @param _owner Ethereum address of the security token owner
    /// @param _polyTokenAddress Ethereum address of the POLY token contract
    /// @param _polyCustomersAddress Ethereum address of the PolyCustomers contract
    /// @param _polyComplianceAddress Ethereum address of the PolyCompliance contract
    /// @param _polySecurityTokenRegistrar Security Token Registrar address
    function SecurityToken(
        string _name,
        bytes8 _ticker,
        uint256 _totalSupply,
        address _owner,
        bytes32 _template,
        address _polyTokenAddress,
        address _polyCustomersAddress,
        address _polyComplianceAddress,
        address _polySecurityTokenRegistrar
    ) public
    {
        name = _name;
        symbol = _ticker;
        template = _template;
        
        totalSupply = _totalSupply;
        owner = _owner;
        POLY = IERC20(_polyTokenAddress);
        PolyCustomers = Customers(_polyCustomersAddress);
        PolyCompliance = ICompliance(_polyComplianceAddress);
        SecurityTokenRegistrar = ISTRegistrar(_polySecurityTokenRegistrar);
        balances[_owner] = _totalSupply;
    }

    /// Make a new bid to be the legal delegate
    /// @param _fee The bounty fee requested to become legal delegate
    /// @param _expires The timestamp the bid expires at
    /// @param _quorum The percentage of initial shareholders required to freeze bounty funds
    /// @param _vestingPeriod The period of time shareholders can freeze bounty funds
    /// @return bool success
    function makeBid(
        bytes32 _template,
        uint256 _fee,
        uint256 _expires,
        uint32 _quorum,
        uint256 _vestingPeriod,
        address _attestor
    ) public returns (bool success)
    {
        var (jurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(_attestor, msg.sender);
        require(verified == true);
        require(role == 2);
        require(_expires >= now);
        require(_fee > 0);
        require(_vestingPeriod >= 7777777);
        bids[msg.sender] = Bid({fee: _fee, expires: _expires, quorum: _quorum, vestingPeriod: _vestingPeriod, attestor: _attestor});
        return true;
    }

    /// Accept a Delegate's bid
    /// @param _delegate Legal Delegates public ethereum address
    /// @return bool success
    function setDelegate(address _delegate) public onlyOwner returns (bool success) {
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
    function updateComplianceProof(
        bytes32 _newMerkleRoot,
        bytes32 _complianceProof
    ) public onlyOwnerOrDelegate returns (bool success) {
        require(msg.sender == owner || msg.sender == delegate);
        complianceProof = _newMerkleRoot;
        LogUpdatedComplianceProof(_newMerkleRoot, _complianceProof);
        return true;
    }

    /// Set the STO contract address
    /// @param _securityTokenOfferingAddress Ethereum address of the STO contract
    /// @return bool success
    function setSTOContract (
        address _securityTokenOfferingAddress,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyDelegate returns (bool success) {
        require(_securityTokenOfferingAddress != address(0));
        require(complianceProof != 0);
        uint256 fee = SecurityTokenRegistrar.getFee(_securityTokenOfferingAddress);
        address developer = SecurityTokenRegistrar.getCreator(_securityTokenOfferingAddress);
        require(POLY.balanceOf(this) >= fee + allocations[msg.sender]);
        allocations[developer] = fee;
        STO = SecurityTokenOffering(_securityTokenOfferingAddress);
        issuanceEndTime = _endTime;
        LogSetSTOContract(_securityTokenOfferingAddress);
        return true;
    }

    /// Add a verified address to the Security Token whitelist
    /// @param _shareholderAddress Address attempting to join ST whitelist
    /// @return bool success
    function addToWhitelist(address _shareholderAddress) public returns (bool success) {
        require(attestor != address(0));
        require(template != 0);
        var (jurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(bids[delegate].attestor, msg.sender);
        bool requirementsMet = PolyCompliance.checkTemplateRequirements(template, jurisdiction, accredited, role);
        require(requirementsMet);
        shareholders[_shareholderAddress] = true;
        return true;
    }

    /// Allow the bounty to be withdrawn by owner, delegate, and the STO developer at appropriate times
    /// @param _amount Amount of POLY being withdrawn from the bounty
    /// @return bool success
    function withdrawBounty(uint256 _amount) public returns (bool success) {
			if (delegate == address(0)) {
        return POLY.transfer(owner, _amount);
      } else {
				require(now > issuanceEndTime + bids[delegate].vestingPeriod);
        require(freezeBounty == false);
        require(allocations[msg.sender] >= _amount);
				require(POLY.transfer(msg.sender, _amount));
        allocations[msg.sender] = allocations[msg.sender].sub(_amount);
        return true;
      }
    }

    /// Vote to freeze the compliance bounty fund
    /// @param _freezeVote `true` will vote to freeze, `false` will do nothing.
    /// @return bool success
    function voteToFreeze(bool _freezeVote) public returns (bool success) {
      require(delegate != address(0));
      require(now > issuanceEndTime);
      require(now < issuanceEndTime + bountyVestingPeriod);
      require(votes[msg.sender].hasVoted == false);
      if (_freezeVote) {
        yay = yay + issuanceEndBalances[msg.sender];
        yayPercent = yay.mul(100).div(totalSupply);
        if (yayPercent > bids[delegate].quorum) {
          freezeBounty = true;
        }
      }
      votes[msg.sender] = Vote({ hasVoted: true, vote: _freezeVote });
      return true;
    }

		/// @notice `issueSecurityTokens` is used by the STO to issue ST's to shareholders
		///  at the end of the issuance.
		/// @param _contributor The address of the person whose contributing
		/// @param _amount The amount of ST to pay out.
		function issueSecurityTokens(address _contributor, uint256 _amount) public onlySTO {
			require(issuanceEndTime > now);
			require(securityTokensIssued.add(_amount) <= balanceOf(this));
			securityTokensIssued = securityTokensIssued.add(_amount);
			issuanceEndBalances[_contributor] = issuanceEndBalances[_contributor].add(_amount);
		}

		/// @notice `collectIssuance` is used to collect ST tokens
		///  after the issuance period has passed.
		function collectIssuance() public {
			require(now > issuanceEndTime);
			require(issuanceEndBalances[msg.sender] != 0);
			require(transfer(msg.sender, issuanceEndBalances[msg.sender]));
		}

    /// Trasfer tokens from one address to another
    /// @param _to Ethereum public address to transfer tokens to
    /// @param _value Amount of tokens to send
    /// @return bool success
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to] && balances[msg.sender] >= _value && _value > 0) {
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (shareholders[_to] && shareholders[msg.sender] && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
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

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// Approve transfer of tokens manually
    /// @param _spender Address to approve transfer to
    /// @param _value Amount of tokens to approve for transfer
    /// @return bool success
    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (shareholders[_spender]) {
            // @dev the logic on this looks screwey. Worth a look in testing
            require ((_value != 0) && (allowed[msg.sender][_spender] != 0));
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
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
