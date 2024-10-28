const { ethers } = require("ethers");
const fs = require('fs');
const assert = require('assert');
const buildPoseidon = require("circomlibjs").buildPoseidon;

// Testing key
const OWNER_SK = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

// Contracts
const TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const EXCHANGE_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const PACCS_ADDRESS = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";

// Contracts ABI
const TOKEN_ABI = JSON.parse(fs.readFileSync("../contracts/out/Token.sol/Token.json")).abi; 
const PACCS_ABI = JSON.parse(fs.readFileSync("../contracts/out/Paccs.sol/Paccs.json")).abi;

// Set owner wallet
const provider = new ethers.providers.JsonRpcProvider();
const wallet = new ethers.Wallet(OWNER_SK, provider);

// Set the contracts
const token_contract = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, wallet);
const paccs_contract = new ethers.Contract(PACCS_ADDRESS, PACCS_ABI, wallet);

describe('PACCs JS Testing Suite', function () {
    it('Exchange token works.', async () => {
        // build Poseidon hash function
        const poseidon = await buildPoseidon();
        
        // transfer some tokens to the exchange contract
        await token_contract.transfer(EXCHANGE_ADDRESS, 10);
        let balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);

        // top up the user smart wallet
        let com = poseidon.F.toObject(poseidon([12, 34]));
        await paccs_contract.topUp(com, {value: 10});

        // commit to a certain action
        let com_action = poseidon.F.toObject(poseidon([12, 34, 10])); 
        await paccs_contract.commitToAction(12, com_action);

        // order the committed action (the commitment will be 0 in-contract
        // since the amount will be 0 again)
        let new_com = poseidon.F.toObject(poseidon([56, 78]));
        await paccs_contract.orderAction(12, 34, 10, new_com);

        // assert if balance is correct
        new_balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);
        assert(balance.eq(new_balance.add(ethers.BigNumber.from("10"))));
    });
});