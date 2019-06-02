const Splitter = artifacts.require('Splitter');
const SafeMath = artifacts.require('SafeMath')

contract('Splitter', (accounts) => {
    describe('beforeTest', () => {
        beforeEach('should run before each it() in the scope', () => {
            const splitter = await Splitter.new(account2, account3, {from: account1});
        })
    })
    it('balance of contract after sending 1 eth to split function should equal msg.value', async () => {
        // Set up 3 test accounts
        let account1 = accounts[0];
        let account2 = accounts[1];
        let account3 = accounts[2];

        const splitter = await Splitter.deployed(account2, account3, {from: account1});

        const messageValue = await splitter.splitEther( {from: account1, value: web3.utils.toWei("1")} );

        const contractBalance = await splitter.getContractBalance();

        assert.equal(web3.utils.toWei("1"), contractBalance, "Value of message sent should be equal to the contracts balance");
    })
})