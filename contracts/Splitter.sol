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
    // Remainder balance for updating potential claims for carol and bob
    uint remainder;

    // Events
    // Show that either Carol or Bob can claim the accumulated remainder for both of them
    event LogRemainderClaimable(uint indexed remainder, bool indexed claimable);

    // Modifiers
    modifier isAlice() {
        require(alice == msg.sender, "not owner");
        _;
    }
    
    modifier isBobOrCarol() {
        require(msg.sender == bob || msg.sender == carol, "You don't have the necessary permission to call this function");
        _;
    }
    
    modifier sufficientBalance() {
        require(balanceOf[msg.sender] > 0, "Your balance is 0");
        _;
    }
    
    modifier remainderCheck() {
        require(remainder > 0 && SafeMath.mod(remainder, 2) == 0, "No remainder claimable");
        _;
    }
    
    modifier nonZero() {
        require(msg.value > 0, "You cannot send a transaction with value equal to 0");
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
        nonZero
    {       
        // Update balance of Bob and Carol in contract
        uint payout = SafeMath.div(msg.value, 2);
        
        // Check if remainer exists, if yes update remainder
        if (msg.value > payout * 2) {
            remainder += msg.value - (payout * 2);
            // If remainder is divisible by two, trigger event that remainder exists & is claimable
            if (SafeMath.mod(remainder, 2) == 0) { emit LogRemainderClaimable(remainder, true); }
            
        }
        balanceOf[bob] += payout;
        balanceOf[carol] += payout;
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
    
    // Can be called by either Bob or Carol
    function claimRemainder() 
        public
        isBobOrCarol
        remainderCheck
        returns (bool success)
    {
        // Split existing remainder in two
        uint evenPayout = SafeMath.div(remainder, 2);
        // Set remainder to 0;
        remainder = 0;
        // update carols and bobs balance
        balanceOf[carol] += evenPayout;
        balanceOf[bob] += evenPayout;
        // Return true to signal successful update
        return true;
    }
}