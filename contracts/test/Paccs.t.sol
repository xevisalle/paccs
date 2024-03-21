// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Paccs.sol";
import "src/Exchange.sol";
import "src/Token.sol";

contract PaccsTest is Test {
    Token public token;
    Exchange public exchange;
    Paccs public paccs;
    
    function setUp() public {
        token = new Token("Token", "TOK");
        exchange = new Exchange(address(token));
        paccs = new Paccs(address(exchange));
    }

    function test_top_up() public {
        paccs.topUp{value: 10}(1234);
        assertEq(paccs.owner_commitment(), 1234);
    }

    function testFail_top_no_funds() public {
        paccs.topUp(1234);
    }

    function test_commit_to_action() public {        
        paccs.commitToAction(1234);
        assertEq(paccs.tx_commitment(), 1234);
    }

    function test_buyTokens() public {
        token.transfer(address(exchange), 10000);

        uint balance = token.balanceOf(address(this));
        exchange.buyTokens{value: 10}();
        assertEq(balance + 10, token.balanceOf(address(this)));
    }

    function test_orderAction() public {
        token.transfer(address(exchange), 10000);
        hoax(address(paccs), 10000 ether);
        
        uint balance = token.balanceOf(address(paccs));
        paccs.orderAction(10);
        assertEq(balance + 10, token.balanceOf(address(paccs)));
    }
}
