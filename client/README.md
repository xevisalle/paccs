# Client 

This folder contains the client that interacts with the contract. By default it uses a local devnet, that you can set up, and deploy the PACCs contracts on it, by following the instructions in the `contracts` folder.

It also contains the tools required for the communication between a user and a relayer.

## Prerequisities

### Dependencies

You will need **node.js**, install it using [this](https://nodejs.org/en/download/).

You will also need to open a terminal and install the dependencies:

```
npm i
```

And the testing framework:

```
sudo npm i -g mocha
```

You will also need to install `snarkjs`:

```
sudo npm i -g snarkjs
```

And `circom`, using [this guide](https://docs.circom.io/getting-started/installation/).

Finally, get the required submodules:

```
git submodule update --init
```

### Compile the ZKP circuit

We first need to download the powers of tau:

```
curl https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_14.ptau > src/power_14.ptau
```

Check the downloaded file integrity:

```
b2sum src/power_14.ptau > src/downloaded_power_14_hash
diff src/power_14_hash src/downloaded_power_14_hash
```

Verify if the powers of tau are correct:

```
snarkjs powersoftau verify src/power_14.ptau
```

Compile the circuit:

```
circom src/circuit.circom -o src --r1cs --wasm
```

Perform the final setup:

```
snarkjs plonk setup src/circuit.r1cs src/power_14.ptau src/circuit_final.zkey
```

Export the verifying key:

```
snarkjs zkey export verificationkey src/circuit_final.zkey src/verification_key.json
```

## Test

You now can run the tests:

```
mocha --exit
```
