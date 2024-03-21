use dusk_plonk::prelude::*;
use dusk_poseidon::sponge;
use poseidon_merkle::{zk::opening_gadget, Item, Opening, Tree};

#[allow(non_snake_case)]
pub fn prove_commitment<const DEPTH: usize, const ARITY: usize>(
    composer: &mut Composer,
    prover_parameters: &ProverParameters<DEPTH, ARITY>,
) -> Result<(), Error> {
    // APPEND ALL THE PARAMETERS
    let S = composer.append_public(prover_parameters.S);
    let r = composer.append_witness(prover_parameters.r);
    let tx_1 = composer.append_public(prover_parameters.tx_1);
    let tx_2 = composer.append_witness(prover_parameters.tx_2);
    let tx_commitment_pi = composer.append_witness(prover_parameters.tx_commitment);
    let root_pi = composer.append_public(prover_parameters.merkle_proof.root().hash);

    // COMPUTE THE COMMITMENTS
    let top_up_commitment = sponge::gadget(composer, &[S, r]);
    let tx_commitment = sponge::gadget(composer, &[tx_1, tx_2]);

    composer.assert_equal(tx_commitment, tx_commitment_pi);

    // VERIFY THE MERKLE PROOF
    let root = opening_gadget(composer, &prover_parameters.merkle_proof, top_up_commitment);

    composer.assert_equal(root, root_pi);

    Ok(())
}

#[allow(non_snake_case)]
#[derive(Debug, Clone, Copy)]
pub struct ProverParameters<const DEPTH: usize, const ARITY: usize> {
    pub S: BlsScalar,
    pub r: BlsScalar,
    pub tx_1: BlsScalar,
    pub tx_2: BlsScalar,
    pub tx_commitment: BlsScalar,
    pub merkle_proof: Opening<(), DEPTH, ARITY>,
}

impl<const DEPTH: usize, const ARITY: usize> Default for ProverParameters<DEPTH, ARITY> {
    fn default() -> Self {
        let mut tree = Tree::new();

        let item = Item {
            hash: BlsScalar::zero(),
            data: (),
        };

        tree.insert(0, item);
        let merkle_proof = tree.opening(0).expect("There is a leaf at position 0");

        Self {
            S: BlsScalar::default(),
            r: BlsScalar::default(),
            tx_1: BlsScalar::default(),
            tx_2: BlsScalar::default(),
            tx_commitment: BlsScalar::default(),
            merkle_proof,
        }
    }
}
