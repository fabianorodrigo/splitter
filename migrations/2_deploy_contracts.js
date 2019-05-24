const SafeMath = artifacts.require('SafeMath');
const Splitter = artifacts.require('Splitter');

module.exports = function(deployer) {
    deployer.deploy(SafeMath, Splitter);
}