pragma solidity ^0.4.15;

import './Ownable.sol';

contract TokenRegistryFactory is Ownable {
    
    struct securityTokenInformation {
        string name;
        string ticker;
        uint8 decimals;
        uint256 totalSupply;
        address owner;
        //add in contract addressn
        //do we need to add issuance Number? would only be for helping with searching 
        //do we need to grab delegate? becuase delegate can change, and is done seperatly outside of this contract
        //do we need to grab an approval true/ false thing here
        
        
        //should only have to assign a delegate once......
        //add in an expiry for the delegate to complete the Compliance template, so that they could request a new delegate 
    }
    
    //dynamic array that stores each and every tokens main information in struct form "securityTokenInformation"
    securityTokenInformation[] public tokenInfoArray;

    //two mappings used to avoid duplicate names and tickers
    // not sure why, but I can't name any mappings public. i think i have done so before. 
    mapping(string => bool)  nameExists;
    mapping(string => bool)  tickerExists;
    
    mapping(string => securityTokenInformation);
    
    //this mapping lets us figure out where in our dynamic array tokenInfoArray our securityToken we want to search is located, by just giving the TICKER
    mapping(string => uint256) securityTokenIssuanceNumber;
    
    //do we need to log more than these three? other important would be owner and total supply. decimals not so important I dont think 
    event LOG_NewSecurityTokenCreated (, string indexed securityTokenTicker); //add in expiry, as well as the bounty ADD TOKEN CONTRACT ADDRESS for front end , just index ticker and contract address
    
    //two function calls, add bounty for delveoeprs and legal bounty , in the ST contractn , not this one , it will transfer POLY 
        //need to connec tthis to the ropsten delpoyed one 
        
        //propse bid function
    

    //could add in other functionality for owner in future
    function TokenRegistryFactory () {
        //Ownable(); maybe I dont have to do this at all
    }

    //creates the Security token contract and saves info within this contract
    function createSecurityToken (string _name, string _ticker, uint8 _decimals, uint256 _totalSupply, address _owner) external {
        
        //check if the name exists in our mapping of all names. if so revert, no duplicate names. if not, record new name in mapping
        if (nameExists[_name] == true) {
            revert();
        } else {
            nameExists[_name] = true;
        }
        //check if the ticker exists in our mapping of all ticker. if so revert, no duplicate tickers. if not, record new ticker in mapping
        if (tickerExists[_ticker] == true) {
            revert();
        } else {
            tickerExists[_ticker] = true;
        }
        
        //we use the ticker here because it has to be unique, and it is the most straightforward way to search up our specific token when needed
        //EDGE CASE - need to make sure work flow of this doesnt overwrite stuff in case of failure
        uint256 issuanceNumber = tokenInfoArray.length;
        
        //as far as I know right now, new SecurityToken will have to point to an actual address that is deployed with this code, like so:
            // address SecurityToken = "0xSf4GSgsdfhrte5yegfdgsDft6u6";
            // for now they are both together in the same solidty file for the remix demo 
            
        address newSecuirtyTokenAddress = new SecurityToken(_name, _ticker, _decimals, _totalSupply, _owner);
       
        //
        securityTokenIssuanceNumber[_ticker] = issuanceNumber; //this has an edge case of being 0, not good, either remove edge case or start at 1 
        securityTokenInformation memory newToken = tokenInfoArray[issuanceNumber];
        
        newToken.name = _name;
        newToken.ticker = _ticker;
        newToken.decimals = _decimals;
        newToken.totalSupply = _totalSupply;
        newToken.owner = _owner;
        
        tokenInfoArray[issuanceNumber] = newToken;
        
        //this event will be watched by web3, and should send a notification to legal delegates, as well as developers
        LOG_NewSecurityTokenCreated (newSecuirtyTokenAddress, _name, _ticker);
    } 


    function () {} //can't send ether with send unless payable modifier exists
}


//an event needs to be added in so that developers and legal delegates are notified of a new token
//does it need an approval tag?
//keep in mind gas costs

