pragma solidity ^0.4.15;

contract Ownable {
    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed _by, address indexed _to);
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Ownable() {
      owner = msg.sender;
    }

    modifier onlyOwner() {
      if (msg.sender != owner) {
        revert();
      }
      _;
    }

    modifier onlyOwnerCandidate() {
      if (msg.sender != newOwnerCandidate) {
        revert();
      }
      _;
    }

    function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
      require(_newOwnerCandidate != address(0));
      newOwnerCandidate = _newOwnerCandidate;
      OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    function acceptOwnership() external onlyOwnerCandidate {
      address previousOwner = owner;
      owner = newOwnerCandidate;
      newOwnerCandidate = address(0);
      OwnershipTransferred(previousOwner, owner);
    }
}
