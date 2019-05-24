const Splitter = artifacts.require('Splitter');
const SafeMath = artifacts.require('SafeMath')

contract('Splitter', (accounts) => {
    it('balance of contract after sending 1 eth to split function should equal msg.value', async () => {
        // Set up 3 test accounts
        account1 = accounts[0];
        account2 = accounts[1];
        account3 = accounts[2];

        safemath = await SafeMath.deployed();
        splitter = await Splitter.deployed(account2, account3, {from: account1});

        messageValue = await splitter.splitEther( {from: account1, value: web3.utils.toWei("1")} );

        contractBalance = await splitter.getContractBalance();

        assert.equal(web3.utils.toWei("1"), contractBalance, "Value of message sent should be equal to the contracts balance");
    })
})