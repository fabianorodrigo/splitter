const Splitter = artifacts.require('Splitter');
// const BigNumber = require('bignumber.js');

// Tests

// Check if two split function calls with uneven amounts split funds equally

// Check if with 3 receivers, 1 receiver has two different remainders he can withdraw after 2 unequal splits have been conducted

// Check if withdraw function works as intended

contract('Splitter', (accounts) => {

    // Set test users
    var sender1 = accounts[0];
    var sender2 = accounts[1]
    var receiver1 = accounts[2];
    var receiver2 = accounts[3];
    var receiver3 = accounts[4];


    beforeEach('should run before each it() in the scope', async () => {
        const splitter = await Splitter.new({from: sender1});
    });
    
    // Check if Split function of an even number splits amount equally
    it('sender1 sending an even number should result in receivers balance updating equally 50/50', async () => {
        const splitter = await Splitter.new({from: sender1});
        let amount = 1000;
        let expectedBalance = 500;
        
        // Call splitEther function in contract
        txReceipt = await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )

        // query balance within contract of receiver1
        balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.equal(expectedBalance, balanceReceiver1, "Balance must be 500wei");
    })
})