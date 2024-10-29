# PACCs circuit in `dusk-plonk`

This folder contains the circuit used in the PACCs protocol, but implemented using the `dusk-plonk` Rust implementation of Plonk. It doesn't integrate with the rest of our stack, we provide it just for the sake of benchmarking.

## Prerequisites

You will need Rust to execute this code. You can follow the official [guide](https://www.rust-lang.org/tools/install).

## Testing

You can execute the tests by running:

```
cargo t --release
```

## Benchmarks

You can execute the benchmarks by running:

```
cargo bench
```
