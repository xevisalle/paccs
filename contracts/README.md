# Contracts

This folder contains the code related to the smart contracts involved in the PACCs protocol. Likewise it contains an explanation on how to test and deploy them using a development network.

## Prerequisities

You will need **Foundry**, a development toolkit for smart contracts and Ethereum-based applications. Install it using [these instructions](https://getfoundry.sh/). You will also need the following dependencies:

```
forge install foundry-rs/forge-std --no-git
forge install openzeppelin/openzeppelin-contracts --no-git
```

## Usage

Our code contains three contracts: the *Token* contract that deploys an ERC-20 token, the *Exchange* contract that deploys a DEX application, and the *Paccs* contract being our protocol's smart contract. You can test them by running:

```
forge test
```

Now you can deploy a devnet by opening a terminal and running:

```
anvil
```

Now compile and deploy the contracts in our local devnet, as follows (in that particular order, so that the tests will work):

```
forge create Token --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --constructor-args "Token" "TOK"
forge create Exchange --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --constructor-args "0x5FbDB2315678afecb367f032d93F642f64180aa3"
forge create Paccs --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --constructor-args "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
```

You can now test and use the clent using the instructions in the `client` folder.
