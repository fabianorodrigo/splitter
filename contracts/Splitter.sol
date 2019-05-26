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
    address payable public bob;
    // Get Carols Balance
    address payable public carol;
    // Remainder balance for updating potential claims for carol and bob
    uint remainder;

    // Events
    // Show that either Carol or Bob can claim the accumulated remainder for both of them
    event LogRemainderClaimable(uint indexed remainder, bool indexed claimable);

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
    
    ///@dev Check if the contract instance 1) has any remainder and 2) if it is divisible by 2, ie. claimable by Carol or Bob
    modifier remainderCheck() {
        require(remainder > 0 && remainder.mod(2) == 0, "No remainder claimable");
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

    // Getter Functions
    
    // @dev Return the ether balance of the contract instance
    // DELETE - ALL BALANCES ARE AVAILABLE EVERYWHERE
    // function getContractBalance()
    //     public
    //     view
    //     returns (uint contractBalance)
    // {
    //     return address(this).balance;
    // }
    
    // Setter Functions

    ///@dev Split ether sent by Alice into two equal pices and add them to Carols and Bobs inherent balance, equally.
    ///@dev If ether amount cannot be divided by two, store remainder in the 'remainder' state variable
    ///@dev If the ether stored in the remainder state variable is again divisible by 2, emit an event
    function splitEther() 
        public
        isAlice
        payable
        nonZero
    {       
        uint payout = msg.value.div(2);
        // Check if remainer exists, if yes update remainder
        if (msg.value > payout * 2) {
            remainder += msg.value - (payout * 2);
            // If remainder is divisible by two, trigger event that remainder exists & is claimable
            if (remainder.mod(2) == 0) { emit LogRemainderClaimable(remainder, true); }
            
        }
        balanceOf[carol] = balanceOf[carol].add(payout);
        balanceOf[bob] = balanceOf[bob].add(payout);
    }
    
    ///@dev Enable Bob & Carol to withdraw the value of their contracts balance
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
    
    ///@dev Enable Carol or Bob to add the ether stored in the 'remainder' state variable to be added equally to their contract balances
    ///@dev Only callable if remainder is equally divisible by 2
    function claimRemainder() 
        public
        isBobOrCarol
        remainderCheck
        returns (bool success)
    {
        // Split existing remainder in two
        uint evenPayout = remainder.div(2);
        // Set remainder to 0;
        remainder = 0;
        // update carols and bobs balance
        balanceOf[carol] = balanceOf[carol].add(evenPayout);
        balanceOf[bob] = balanceOf[bob].add(evenPayout);
        // Return true to signal successful update
        return true;
    }
}