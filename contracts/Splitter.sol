pragma solidity 0.5.6;

contract Splitter {

    /*there are 3 people: Alice, Bob and Carol.
    
    we can see the balances of Alice, Bob and Carol on the Web page.
    Alice can use the Web page to split her ether.
    */
    // State variables

    // Splitter contract balance
    uint public splitterBalance;
    // balance of alice, bob & carol
    mapping (address => uint) balanceOf;
    // define parties
    address public alice;
    address payable public bob;
    address payable public carol;
    // Set owner of contract
    address owner;

    // Modifiers
    modifier isAlice() {
        require(alice == msg.sender);
        _;
    }
    
    // Constructor setting contract owner
    constructor (address firstAlice) public {
        owner = msg.sender;
        alice = firstAlice;
    }

    // whenever Alice sends ether to the contract for it to be split, half of it goes to Bob and the other half to Carol.
    function splitEther(uint amount) 
        public
        isAlice
        payable 
    returns (bool splitted) 
    {
        
        // NOT SECURE needs to be safeMath
        bob.transfer(amount / 2);
        carol.transfer(amount / 2);
        return true;
    }


    

    

    // Functions
}