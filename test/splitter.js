const Splitter = artifacts.require('Splitter');
// const BigNumber = require('bignumber.js');

// Tests

contract('Splitter', (accounts) => {

    // Set test users
    var sender1 = accounts[0];
    var sender2 = accounts[1]
    var receiver1 = accounts[2];
    var receiver2 = accounts[3];
    var receiver3 = accounts[4];


    beforeEach(async () =>  {
        splitter = await Splitter.new({from: sender1});
    });
    
    // Check if Split function of an even number splits amount equally
    it('sender1 sending an even number should result in receivers balance updating equally 50/50', async () => {
        // const splitter = await Splitter.new({from: sender1});
        let amount = 1000;
        let expectedBalance = 500;
        
        // Call splitEther function in contract
        txReceipt = await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )

        // query balance within contract of receiver1
        balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.equal(expectedBalance, balanceReceiver1, "Balance must be 500wei");
    })

    // Check if two split function calls with uneven amounts split funds equally
    it('sending uneven amounts to split function twice should update receivers balance', async () => {
        let amount = 1;
        let expectedBalance = 1;

        // Call splitEther function in contract twice
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )

        balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.equal(expectedBalance, balanceReceiver1)
    })

    // Check if with 3 receivers, 1 receiver has two different remainders he can withdraw after 2 unequal splits have been conducted

    it('A single receiver1 can have to different remainder balances with two different receiver2s', async() => {
        let amount = 1;
        let endBalance = 2;
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} );
        await splitter.splitEther(receiver1, receiver3, {from: sender1, value: amount} );
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} );
        await splitter.splitEther(receiver1, receiver3, {from: sender1, value: amount} );

        balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.equal(balanceReceiver1, endBalance);
    })
    // Check if withdraw function works as intended
    it('withdraw func works', async() => {
        let amount = 10000000000000000000; 

        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} );

        const receiver1BalanceBefore = await web3.eth.getBalance(receiver1);

        await splitter.withdraw( {from:receiver1} )

        const receiver1BalanceAfter = await web3.eth.getBalance(receiver1);

        assert.isAbove(parseInt(receiver1BalanceAfter), parseInt(receiver1BalanceBefore));
    })
})