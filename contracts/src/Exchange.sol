// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Exchange is Ownable {
    Token token;

    constructor(address tokenAddress) Ownable(msg.sender) {
        token = Token(tokenAddress);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "User didn't pay Ether.");

        uint256 amountToBuy = msg.value;
        require(token.balanceOf(address(this)) >= amountToBuy, "Not enough TOK in contract.");

        bool sent = token.transfer(msg.sender, amountToBuy);
        require(sent, "Exchange failed.");
    }
}