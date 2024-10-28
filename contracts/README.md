# Contracts

This folder contains the code related to the smart contracts involved in the PACCs protocol. Likewise it contains an explanation on how to test and deploy them using a development network.

## Prerequisities

You will need **Foundry**, a development toolkit for smart contracts and Ethereum-based applications. Install it using [these instructions](https://getfoundry.sh/). You will also need the following dependencies:

```
forge install foundry-rs/forge-std --no-git
forge install openzeppelin/openzeppelin-contracts --no-git
```

You will also need to download the submodules:

```
git submodule update --init
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

Now compile and deploy the contracts (and the Poseidon libraries) in our local devnet, as follows:

```
bash deploy.sh
```

You can now test and use the clent using the instructions in the `client` folder.
