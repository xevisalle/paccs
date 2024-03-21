// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Exchange.sol";

contract Paccs {
    address payable public owner;
    Exchange exchange;

    uint256 public owner_commitment;
    uint256 public tx_commitment;

    constructor(address exchangeAddress) {
        owner = payable(msg.sender);
        exchange = Exchange(exchangeAddress);
    }

    receive() external payable {}

    function withdraw(uint _amount) external {
        require(msg.sender == owner, "Caller is not owner.");
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function topUp(uint256 commitment) public payable {
        require(address(this).balance > 0, "Not enough balance to cover fee + collateral.");
        owner_commitment = commitment;
    }

    function commitToAction(uint256 commitment) public {
        tx_commitment = commitment;
    }

    function orderAction(uint256 amountToBuy) public {
        exchange.buyTokens{value: amountToBuy}();
    }
}
