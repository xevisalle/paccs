forge create Token --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --constructor-args "Token" "TOK"
forge create Exchange --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --constructor-args "0x5FbDB2315678afecb367f032d93F642f64180aa3"
forge create src/poseidon-solidity/contracts/PoseidonT3.sol:PoseidonT3 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
forge create src/poseidon-solidity/contracts/PoseidonT4.sol:PoseidonT4 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
forge create Paccs --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --constructor-args "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512" "0x5FbDB2315678afecb367f032d93F642f64180aa3" --libraries src/poseidon-solidity/contracts/PoseidonT3.sol:PoseidonT3:0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 --libraries src/poseidon-solidity/contracts/PoseidonT4.sol:PoseidonT4:0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9