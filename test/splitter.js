const Splitter = artifacts.require('Splitter');
// const BigNumber = require('bignumber.js');

// Tests

contract('Splitter', (accounts) => {

    // Set test users
    const [sender1, sender2 ,receiver1, receiver2, receiver3] = accounts;
    let splitter;


    beforeEach(async () =>  {
        splitter = await Splitter.new({from: sender1});
    });
    
    // Check if Split function of an even number splits amount equally
    it('sender1 sending an even number should result in receivers balance updating equally 50/50', async () => {
        // const splitter = await Splitter.new({from: sender1});
        let amount = 1000;
        let expectedBalance = 500;
        
        // Call splitEther function in contract
        const txReceipt = await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )

        // query balance within contract of receiver1
        const balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.equal(expectedBalance, balanceReceiver1, "Balance must be 500wei");
    })

    // Check if two split function calls with uneven amounts split funds equally
    it('sending uneven amounts to split function twice should update receivers balance', async () => {
        let amount = 1;
        let expectedBalance = 1;

        // Call splitEther function in contract twice
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} )

        const balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.strictEqual(expectedBalance, balanceReceiver1.toNumber())
    })

    // Check if with 3 receivers, 1 receiver has two different remainders he can withdraw after 2 unequal splits have been conducted

    it('A single receiver1 can have to different remainder balances with two different receiver2s', async() => {
        let amount = 1;
        let endBalance = 2;
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} );
        await splitter.splitEther(receiver1, receiver3, {from: sender1, value: amount} );
        await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} );
        await splitter.splitEther(receiver1, receiver3, {from: sender1, value: amount} );

        const balanceReceiver1 = await splitter.balanceOf(receiver1);

        assert.equal(balanceReceiver1, endBalance);
    })
    // Check if withdraw function works as intended
    it('withdraw func works', async() => {
        let amount = 10000000000000000000; 

        const txReceipt1 = await splitter.splitEther(receiver1, receiver2, {from: sender1, value: amount} );

        const receiver1BalanceBefore = await web3.eth.getBalance(receiver1);

        const txReceipt2 = await splitter.withdraw( {from:receiver1} );

        const tx2 = await web3.eth.getTransaction(txReceipt2.tx);


        const gasCost2 = tx2.gasPrice * txReceipt2.receipt.gasUsed;


        const receiver1BalanceAfter = await web3.eth.getBalance(receiver1);

        console.log(receiver1BalanceAfter);
        console.log(parseInt(receiver1BalanceAfter));
        console.log(gasCost2);
        console.log(10000000000000000000/2);

        const realBalanceAfter =  parseInt(receiver1BalanceAfter) + gasCost2 - (10000000000000000000/2);

        console.log(receiver1BalanceBefore);
        console.log(realBalanceAfter);

        assert.equal(parseInt(receiver1BalanceBefore), realBalanceAfter);
    })
})