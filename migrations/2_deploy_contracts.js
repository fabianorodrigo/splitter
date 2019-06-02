const SafeMath = artifacts.require('SafeMath');
const Splitter = artifacts.require('Splitter');

module.exports = function(deployer, network, accounts) {
    deployer.deploy(Splitter, accounts[1], accounts[2], {from: accounts[0]});
}