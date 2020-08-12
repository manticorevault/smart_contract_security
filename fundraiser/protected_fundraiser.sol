pragma solidity ^0.4.24;

contract Fundraiser {
    mapping(address => uint) balances;
    
    function withdrawCoins() public{
        uint withdrawAmount = balances[msg.sender];
        //Simply by moving the balances[msg.sender] = 0 and thus setting the balance
        //to 0 before the payout occurs, you can prevent the drain to reset the function
        //midway. Even if the recursion happens, the value will bet set to 0 and it will
        //return 0 ETH every time, saving money from the original contract
        balances[msg.sender] = 0;
        Wallet wallet = Wallet(msg.sender);
        wallet.payout.value(withdrawAmount)();
        
        
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

