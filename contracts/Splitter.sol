pragma solidity >=0.4.21 <0.6.0;

import './SafeMath.sol';


/// @title Splitter - Split payments to two parties 50/50
/// @author hilmarx
/// @notice You can use this contract to split up payments equally among two pre-defined parties
/// @dev This is a test version, please don't use in production

contract Splitter  {


    using SafeMath for uint256;

    // State variables

    // balance of alice, bob & carol
    mapping (address => uint) public balanceOf;

    // Get Alice address
    address public alice;
    // Get Bobs Balance
    address public bob;
    // Get Carols Balance
    address public carol;
    // Remainder balance for updating potential claims for carol and bob
    uint remainder;

    // Events
    // Show that the remainder was distributed to the two accounts
    event LogRemainderClaimed(uint indexed remainder, bool indexed claimable);

    // Show that alice sent some Ether to the split function
    event LogSplit(uint indexed amount);

    // Show that either bob or carol successfully withdrew their balance
    event LogBalanceWithdrawn(address indexed withdrawer, uint indexed amount);

    // Modifiers
    ///@dev Check if message sender is Alice
    modifier isAlice() {
        require(alice == msg.sender, "not owner");
        _;
    }
    
    ///@dev Check if message sender is either Bob or Carol
    modifier isBobOrCarol() {
        require(msg.sender == bob || msg.sender == carol, "You don't have the necessary permission to call this function");
        _;
    }
    
    ///@dev Check if message sender (Bob or Carol) have any balance which can be withdrawn
    modifier sufficientBalance() {
        require(balanceOf[msg.sender] > 0, "Your balance is 0");
        _;
    }
    
    ///@dev Check that Alice is not sending a message with value 0 to a payable method
    modifier nonZero() {
        require(msg.value > 0, "You cannot send a transaction with value equal to 0");
        _;
    }
    
    //@dev Constructor setting addresses & balances of Alice, Bob & Carol, where alice is the owner
    constructor(address payable bobAddress, address payable carolAddress) public {
        alice = msg.sender;
        bob = bobAddress;
        balanceOf[bob];
        carol = carolAddress;
        balanceOf[carol];
    }

    // Setter Functions

    ///@dev Split ether sent by Alice into two equal pices and add them to Carols and Bobs inherent balance, equally.
    ///@dev If ether amount cannot be divided by two, store remainder in the 'remainder' state variable
    ///@dev If the ether stored in the remainder state variable is again divisible by 2, emit an event
    function splitEther() 
        public
        isAlice
        nonZero
        payable
    {       
        uint payout = msg.value.div(2);
        // Check if remainer exists, if yes update remainder
        if (msg.value > payout * 2) {
            remainder = remainder.add(msg.value - (payout * 2));
            // If remainder is greater than 0 & divisible by two, trigger event and update carols and bobs balanceOf
            if (remainder > 0 && remainder.mod(2) == 0) 
            {
                // Split existing remainder in two
                uint evenPayout = remainder.div(2);
                // Set remainder to 0;
                remainder = 0;
                // update carols and bobs balance
                balanceOf[carol] = balanceOf[carol].add(evenPayout);
                balanceOf[bob] = balanceOf[bob].add(evenPayout);
                emit LogRemainderClaimed(remainder, true);
            }  
        }
        balanceOf[carol] = balanceOf[carol].add(payout);
        balanceOf[bob] = balanceOf[bob].add(payout);

        // Emit event that ether was succesfully splitted amoung bob & carol
        emit LogSplit(msg.value);
    }
    
    ///@dev Enable Bob & Carol to withdraw the value of their contracts balance
    function withdraw() 
        public
        isBobOrCarol
        sufficientBalance
        returns (bool success)
    {
        uint withdrawAmount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(withdrawAmount);
        // emit event that either carol or bob successfully withdrew their balance
        emit LogBalanceWithdrawn(msg.sender, withdrawAmount);
        return true;
    }
    
}