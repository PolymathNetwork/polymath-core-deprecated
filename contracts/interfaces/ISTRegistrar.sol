pragma solidity ^0.4.18;

interface ISTRegistrar {

   /**
    * @dev Creates a new Security Token and saves it to the registry
    * @param _name Name of the security token
    * @param _ticker Ticker name of the security
    * @param _totalSupply Total amount of tokens being created
    * @param _owner Ethereum public key address of the security token owner
    * @param _decimals Divisibility of the security token
    * @param _host The host of the security token wizard
    * @param _fee Fee being requested by the wizard host
    * @param _type Type of security being tokenized
    * @param _lockupPeriod Length of time raised POLY will be locked up for dispute
    * @param _quorum Percent of initial investors required to freeze POLY raise
    */
    function createSecurityToken (
        string _name,
        string _ticker,
        uint256 _totalSupply,
        address _owner,
        uint8 _decimals,
        address _host,
        uint256 _fee,
        uint8 _type,
        uint256 _lockupPeriod,
        uint8 _quorum
    ) external;

     /**
     * @dev Allow POLY allocations to be withdrawn by owner, delegate, and the STO auditor at appropriate times
     * @param _ticker Symbol of the security token
     * @return bool success
     */
    function withdrawFunds(string _ticker) public returns (bool success);
}
