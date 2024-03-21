const { ethers } = require("ethers");
const fs = require('fs');
const wait = require('wait');
const assert = require('assert');

// Testing keys
const OWNER_SK = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const RECEIVER_PK = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

// Contracts
const TOKEN_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const EXCHANGE_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const WALLET_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

// Contracts ABI
const TOKEN_ABI = JSON.parse(fs.readFileSync("../contracts/out/Token.sol/Token.json")).abi; 
const EXCHANGE_ABI = JSON.parse(fs.readFileSync("../contracts/out/Exchange.sol/Exchange.json")).abi; 
const WALLET_ABI = JSON.parse(fs.readFileSync("../contracts/out/Wallet.sol/Wallet.json")).abi;

// Set owner wallet
const provider = new ethers.providers.JsonRpcProvider();
const wallet = new ethers.Wallet(OWNER_SK, provider);

describe('PACCs JS Testing Suite', function () {
    this.timeout(1000000000);

    it('Send token works.', async () => {
        let token_contract = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, wallet);
        let balance = await token_contract.balanceOf(RECEIVER_PK);

        await token_contract.transfer(RECEIVER_PK, 100000);
        assert(!balance.eq(await token_contract.balanceOf(RECEIVER_PK)));
    });
    
    it('Buy tokens works.', async () => {
        let token_contract = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, wallet);
        let exchange_contract = new ethers.Contract(EXCHANGE_ADDRESS, EXCHANGE_ABI, wallet);
        let wallet_contract = new ethers.Contract(WALLET_ADDRESS, WALLET_ABI, wallet);

        // transfer some tokens to the exchange contract
        await token_contract.transfer(EXCHANGE_ADDRESS, 100000);
        let balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);

        // now buy the same amount of tokens (conversion with Ether 1:1)
        await exchange_contract.buyTokens({value: ethers.utils.parseUnits("0.0000000000001", 18)});
        let new_balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);
        assert(balance.eq(new_balance.add(ethers.BigNumber.from("100000"))));

        wallet.sendTransaction({
            to: WALLET_ADDRESS,
            value: 10
        });

        await wait(200);

        await token_contract.transfer(EXCHANGE_ADDRESS, 10);

        balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);
        await wallet_contract.orderExchange(10);
        new_balance = await token_contract.balanceOf(EXCHANGE_ADDRESS);
        assert(balance.eq(new_balance.add(ethers.BigNumber.from("10"))));
    });
});