# Private, Anonymous, Collateralizable Commitments (PACCs) Proof-of-Concept

This repository contains a Proof-of-Concept of PACCs, a protocol meant to prevent MEV attacks on different kind of Blockchain scenarios such as Decentralized Exchanges (DEXs). An academic paper describing the main idea behind this implementation can be found [here](https://arxiv.org/pdf/2301.12818).

**DISCLAIMER**: the code in this repository is currently **unstable**. Furthermore, **it has not gone through an exhaustive security analysis**, so it is not intended to be used in a production environment, only for academic purposes.

## Getting Started

This repository consists of the following modules:

- :computer: [**Client**](client): All the tools needed to use the protocol (i.e. interact with the smart contract , generate zero-knowledge proofs for the relayer, verify them, etc.).
- :pencil: [**Contracts**](contracts): The smart contracts, along with all the required code to test and deploy them.
- :bar_chart: [**Zkp**](zkp): A folder implementing the circuit used in our protocol, using Rust. Intended to be used for benchmarking purposes.
