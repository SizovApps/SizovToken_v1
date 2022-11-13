const Web3 = require('web3')
var web3 = new Web3(new Web3.providers.HttpProvider("https://goerli.infura.io/v3/864615bc4564464082ec84a0d7a99cb2"));

const address = "0x459462475AEf6F258099356793D4e06ebD04BFd4";

const contract = require("../artifacts/contracts/SizovToken.sol/SizovToken.json");


// console.log(web3.eth.getBalance); // проверяем
const myContract = new web3.eth.Contract(contract.abi, address)
myContract.methods.getMessage ().call().then(console.log)
