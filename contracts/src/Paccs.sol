// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Exchange.sol";
import "./poseidon-solidity/contracts/PoseidonT3.sol";
import "./poseidon-solidity/contracts/PoseidonT4.sol";

contract Paccs {
    struct User {
        uint ether_balance;
        uint tok_balance;
        uint commitment;
    }

    using PoseidonT3 for uint256[2];
    using PoseidonT4 for uint256[3];

    mapping(address => User) public users;
    mapping(uint256 => uint) public tx_commitments; // S => tx

    Exchange exchange;
    Token token;

    uint public collateral = 0;

    constructor(address exchangeAddress, address tokenAddress) {
        exchange = Exchange(exchangeAddress);
        token = Token(tokenAddress);
    }

    receive() external payable {}

    function withdraw_ether(uint _amount, uint256 s, uint256 r, uint commitment) external {
        require(users[msg.sender].ether_balance >= _amount, "Not enough balance.");
        require(users[msg.sender].commitment == [s, r].hash() || users[msg.sender].commitment == 0, "Provided opening not correct.");
        require(tx_commitments[s] == 0, "An existing committed transaction was never issued.");

        if(users[msg.sender].ether_balance > collateral) {
            users[msg.sender].commitment = commitment;
        }
        else {
            users[msg.sender].commitment = 0;
        }

        users[msg.sender].ether_balance -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function withdraw_token(uint _amount) external {
        users[msg.sender].tok_balance -= _amount;
        token.transfer(msg.sender, _amount);
    }

    // GETTERS
    
    function getUserEtherBalance(address user_address) external view returns (uint) {
        return users[user_address].ether_balance;
    }

    function getUserTokBalance(address user_address) external view returns (uint) {
        return users[user_address].tok_balance;
    }

    function getUserCommitment(address user_address) external view returns (uint) {
        return users[user_address].commitment;
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // PACCS METHODS
    
    function topUp(uint commitment) public payable {
        users[msg.sender].ether_balance += msg.value;

        if(users[msg.sender].ether_balance > collateral && users[msg.sender].commitment == 0) {
            users[msg.sender].commitment = commitment;
        }
    }

    // TODO: check what's needed to prevent relayer spoofing:
    // e.g. sniff S and send it in advance to the network with a
    // random tx_commitment, burning user funds
    function commitToAction(uint256 s, uint tx_commitment) public {
        tx_commitments[s] = tx_commitment;
    }

    function orderAction(uint256 s, uint256 r, uint _amountToBuy, uint commitment) public {
        require(users[msg.sender].ether_balance >= _amountToBuy, "Not enough Ether to order the action.");
        require(users[msg.sender].commitment == [s, r].hash(), "Provided opening not correct.");
        require(tx_commitments[s] == [s, r, _amountToBuy].hash(), "Transaction was never committed.");
        
        users[msg.sender].ether_balance -= _amountToBuy;
        exchange.buyTokens{value: _amountToBuy}();
        users[msg.sender].tok_balance += _amountToBuy;

        if(users[msg.sender].ether_balance > collateral) {
            users[msg.sender].commitment = commitment;
        }
        else {
            users[msg.sender].commitment = 0;
        }

        tx_commitments[s] = 0;
    }
}
