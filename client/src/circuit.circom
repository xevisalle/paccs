pragma circom 2.0.0;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/mux1.circom";

template Circuit(nLevels) {
    signal input S;
    signal input r;
    signal input value;

    signal output hash_tx;

    signal input pathIndices[nLevels];
    signal input siblings[nLevels];

    signal output root;

    component poseidons[nLevels];
    component mux[nLevels];

    component poseidon_tx = Poseidon(3);
    poseidon_tx.inputs[0] <== S;
    poseidon_tx.inputs[1] <== r;
    poseidon_tx.inputs[2] <== value;

    hash_tx <== poseidon_tx.out;

    component poseidon_Sr = Poseidon(2);
    poseidon_Sr.inputs[0] <== S;
    poseidon_Sr.inputs[1] <== r;

    signal hashes[nLevels + 1];
    hashes[0] <== poseidon_Sr.out;

    // compute the Merkle root, as done
    // in Semaphore's "tree.circom":
    for (var i = 0; i < nLevels; i++) {
        pathIndices[i] * (1 - pathIndices[i]) === 0;

        poseidons[i] = Poseidon(2);
        mux[i] = MultiMux1(2);

        mux[i].c[0][0] <== hashes[i];
        mux[i].c[0][1] <== siblings[i];

        mux[i].c[1][0] <== siblings[i];
        mux[i].c[1][1] <== hashes[i];

        mux[i].s <== pathIndices[i];

        poseidons[i].inputs[0] <== mux[i].out[0];
        poseidons[i].inputs[1] <== mux[i].out[1];

        hashes[i + 1] <== poseidons[i].out;
    }

    root <== hashes[nLevels];
}

component main = Circuit(4);