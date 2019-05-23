pragma solidity 0.5.8;

import { SafeMath } from './SafeMath.sol';

contract Splitter {

    // State variables

    // balance of alice, bob & carol
    mapping (address => uint) public balanceOf;

    // Get Alice address
    address public alice;
    // Get Bobs Balance
    address public bob;
    // Get Carols Balance
    address public carol;

    // Modifiers
    modifier isAlice() {
        require(alice == msg.sender);
        _;
    }
    
    // Constructor setting addresses & balances of Alice, Bobs address & Carols address
    constructor(address bobAddress, address carolAddress) public {
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
    
    function getAliceBalance()
        public
        view
        returns (uint aliceBalance)
    {
        return alice.balance;
    }
    
    // Setter Functions

    // whenever Alice sends ether to the contract for it to be split, half of it goes to Bob and the other half to Carol.
    function splitEther(uint amount) 
        public
        isAlice
        payable 
    {       
        // send money to contract
        // Update balance of Bob and Carol in contract
        balanceOf[bob] += SafeMath.div(amount, 2);
        balanceOf[carol] += SafeMath.div(amount, 2);
    }
}