const { ethers } = require("ethers");
const fs = require('fs');
const assert = require('assert');

// Testing key
const OWNER_SK = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// Contracts
const TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const EXCHANGE_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const PACCS_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

// Contracts ABI
const TOKEN_ABI = JSON.parse(fs.readFileSync("../contracts/out/Token.sol/Token.json")).abi; 
const PACCS_ABI = JSON.parse(fs.readFileSync("../contracts/out/Paccs.sol/Paccs.json")).abi;

// Set owner wallet
const provider = new ethers.providers.JsonRpcProvider();
const abiCoder = new ethers.utils.AbiCoder();
const wallet = new ethers.Wallet(OWNER_SK, provider);

describe('PACCs JS Testing Suite', function () {
    it('Exchange token works.', async () => {
        let token_contract = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, wallet);
        let paccs_contract = new ethers.Contract(PACCS_ADDRESS, PACCS_ABI, wallet);

        // transfer some tokens to the exchange contract
        await token_contract.transfer(EXCHANGE_ADDRESS, 10);
        let balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);

        // top up the user smart wallet
        let com = ethers.utils.keccak256(abiCoder.encode([ "uint", "uint" ], [ 1234, 5678 ]));
        await paccs_contract.topUp(com, {value: 10});

        // commit to a certain action
        let com_action = ethers.utils.keccak256(abiCoder.encode([ "uint", "uint", "uint" ], [ 1234, 5678, 10 ]));     
        await paccs_contract.commitToAction(1234, com_action);

        // order the committed action
        let new_com = ethers.utils.keccak256(abiCoder.encode([ "uint", "uint" ], [ 1234, 5678 ]));
        await paccs_contract.orderAction(1234, 5678, 10, new_com);

        new_balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);
        assert(balance.eq(new_balance.add(ethers.BigNumber.from("10"))));
    });
});