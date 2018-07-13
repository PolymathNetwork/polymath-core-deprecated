pragma solidity ^0.4.18;


interface INameSpaceRegistrar {

    function changeAdmin(address _admin, bool _valid)  public;
    function changeTokenOwner(string _nameSpace, string _symbol, address _newOwner) public;
    function registerToken(string _nameSpace, string _symbol, string _description, string _contact, address _owner) public;
    function getDetails(string _nameSpace, string _symbol) view public returns (address, uint256);
    function getDescription(string _nameSpace, string _symbol) view public returns (string, string);

}