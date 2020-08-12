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
        
    }
}

