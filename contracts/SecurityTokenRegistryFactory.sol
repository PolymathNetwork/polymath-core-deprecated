pragma solidity ^0.4.15;

import './SecurityToken.sol';
import './Ownable.sol';

contract SecurityTokenRegistryFactory is Ownable {
    
    uint256 public numberOfTokensCreated;
    
    //we do not include bounty, expiry, delegate, or approval in here right now as they are all subject to change.  
    //everything within here is permanent from creation 
    struct SecurityTokenInformation {
        string name;
        uint8 decimals;
        uint256 totalSupply;
        address owner;
        address tokenAddress;
    }
    
    //map the TICKER to the struct. therefore only need to record ticket at the pointer 
    mapping(string => SecurityTokenInformation) mapTickerToStructInfo;
    
    //moved into security token contract 
    //event LOG_NewSecurityTokenCreated (address indexed securityTokenAddress, string indexed securityTokenTicker, uint256 bounty, uint256 expiry); 

    //owner comes from is ownable. no use for constructor funciton at the moment 
    //function SecurityTokenRegistryFactory () {}

    //creates the Security token contract and saves info within this contract
    function createSecurityToken (string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner) external {
        
        //will need to add in requirements for each variable. i.e. string != "", ticker.length 0<t<5, decimals <18, etc. 
        
        //check if the ticker exists in our mapping of all tickers. if so revert, no duplicate tickers. if not, continue to record new ticker in mapping
        //decimals will only be 0 if the ticker has not been taken, because it has to be greater than 1 when created
        if (mapTickerToStructInfo[_ticker].decimals != 0) {
            revert();
        }
        
        // new SecurityToken will have to point to an actual address that is deployed with this code, like so:
            // address SecurityToken = "0xSf4GSgsdfhrte5yegfdgsDft6u6"; (not the ropsten testnet POLY, but the deployed code of SecurityTokenRegistry
        address newSecuirtyTokenAddress = new SecurityToken(_name, _ticker, _decimals, _totalSupply, _owner);
       
        SecurityTokenInformation memory newToken = mapTickerToStructInfo[_ticker];
        
        newToken.name = _name;
        newToken.decimals = _decimals;
        newToken.totalSupply = _totalSupply;
        newToken.owner = _owner; //should owner be msg.sender?
        newToken.tokenAddress = newSecuirtyTokenAddress;
        
        //update the struct with all new info 
        mapTickerToStructInfo[_ticker] = newToken;
        numberOfTokensCreated++;
    } 


    function () {} //can't send ether with send unless payable modifier exists
}

//need to add in params 