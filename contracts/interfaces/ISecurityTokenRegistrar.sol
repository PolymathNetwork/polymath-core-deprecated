pragma solidity ^0.4.18;

interface ISecurityTokenRegistrar {

   /**
    * @dev Creates a new Security Token and saves it to the registry
    * @param _nameSpace Name space for this security token
    * @param _name Name of the security token
    * @param _ticker Ticker name of the security
    * @param _totalSupply Total amount of tokens being created
    * @param _owner Ethereum public key address of the security token owner
    * @param _type Type of security being tokenized
    */
    function createSecurityToken (
        string _nameSpace,
        string _name,
        string _ticker,
        uint256 _totalSupply,
        uint8 _decimals,
        address _owner,
        uint8 _type
    ) external;

    /**
     * @dev Get Security token details by its ethereum address
     * @param _STAddress Security token address
     */
    function getSecurityTokenData(address _STAddress) public view returns (
      string,
      string,
      address,
      uint8
    );

}
