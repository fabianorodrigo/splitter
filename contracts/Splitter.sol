pragma solidity 0.5.8;

import { SafeMath } from './SafeMath.sol';

contract Splitter {

    // State variables

    // balance of alice, bob & carol
    mapping (address => uint) public balanceOf;

    // Get Alice address
    address public alice;
    // Get Bobs Balance
    address payable public bob;
    // Get Carols Balance
    address payable public carol;

    // Modifiers
    modifier isAlice() {
        require(alice == msg.sender);
        _;
    }
    
    modifier isBobOrCarol() {
        require(msg.sender == bob || msg.sender == carol, "you cannot call this function");
        _;
    }
    
    modifier sufficientBalance() {
        require(balanceOf[msg.sender] > 0, "not enough balance");
        _;
    }
    
    // Constructor setting addresses & balances of Alice, Bobs address & Carols address
    constructor(address payable bobAddress, address payable carolAddress) public {
        alice = msg.sender;
        bob = bobAddress;
        balanceOf[bob] = 0;
        carol = carolAddress;
        balanceOf[carol] = 0;
    }

    // Getter Functions
    
    // Get contracts Balance
    function getContractBalance()
        public
        view
        returns (uint contractBalance)
    {
        return address(this).balance;
    }
    
    /*
    
    function getAliceBalance()
        public
        view
        returns (uint aliceBalance)
    {
        return alice.balance;
    }
    */
    
    // Setter Functions

    // whenever Alice sends ether to the contract for it to be split, half of it goes to Bob and the other half to Carol.
    function splitEther() 
        public
        isAlice
        payable 
    {       
        // check if Alice
        // Update balance of Bob and Carol in contract
        balanceOf[bob] += SafeMath.div(msg.value, 2);
        balanceOf[carol] += SafeMath.div(msg.value, 2);
    }
    
    // Withdrawing funds to bobs or alices address
    function withdraw() 
        public
        isBobOrCarol
        sufficientBalance
        returns (bool success)
    {
        if (msg.sender == bob) 
        {
            bob.transfer(balanceOf[bob]);
            balanceOf[bob] = 0;
            return true;
        } 
        else if (msg.sender == carol) 
        {
            carol.transfer(balanceOf[carol]);
            balanceOf[carol] = 0;
            return true;
        }
        else {
            revert("Withdraw failed");
        }
    }
    
}