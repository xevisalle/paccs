use dusk_plonk::prelude::*;
use dusk_poseidon::sponge;
use poseidon_merkle::{Item, Tree};

use ff::Field;
use rand_core::OsRng;

use zkp::gadget::{prove_commitment, ProverParameters};

static LABEL: &[u8; 12] = b"123456123456";

const CAPACITY: usize = 12;
const DEPTH: usize = 1;
const ARITY: usize = 4;

#[derive(Default, Debug)]
pub struct Paccs {
    prover_parameters: ProverParameters<DEPTH, ARITY>,
}

impl Paccs {
    pub fn new(prover_parameters: ProverParameters<DEPTH, ARITY>) -> Self {
        Self { prover_parameters }
    }
}

impl Circuit for Paccs {
    fn circuit(&self, composer: &mut Composer) -> Result<(), Error> {
        prove_commitment(composer, &self.prover_parameters)?;
        Ok(())
    }
}

#[allow(non_snake_case)]
#[test]
fn test_full_paccs() {
    let pp = PublicParameters::setup(1 << CAPACITY, &mut OsRng).unwrap();

    let (prover, verifier) =
        Compiler::compile::<Paccs>(&pp, LABEL).expect("failed to compile circuit");

    let S = BlsScalar::random(&mut OsRng);
    let r = BlsScalar::random(&mut OsRng);
    let tx_1 = BlsScalar::random(&mut OsRng);
    let tx_2 = BlsScalar::random(&mut OsRng);
    let tx_commitment = sponge::hash(&[tx_1, tx_2]);

    let mut tree = Tree::<(), DEPTH, ARITY>::new();

    let item = Item {
        hash: sponge::hash(&[S, r]),
        data: (),
    };

    let pos = 0;
    tree.insert(pos, item);
    let merkle_proof = tree.opening(pos).expect("Tree was read successfully");

    let prover_parameters = ProverParameters {
        S,
        r,
        tx_1,
        tx_2,
        tx_commitment,
        merkle_proof,
    };

    let (proof, public_inputs) = prover
        .prove(&mut OsRng, &Paccs::new(prover_parameters))
        .expect("failed to prove");

    verifier
        .verify(&proof, &public_inputs)
        .expect("failed to verify proof");
}
