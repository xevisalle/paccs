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
        paccs = new Paccs(address(exchange), address(token));
    }
    
    function test_top_up() public {
        assertEq(paccs.getUserCommitment(address(this)), 0);
        assertEq(paccs.getUserEtherBalance(address(this)), 0);

        bytes32 com = keccak256(abi.encode(1234));
        paccs.topUp{value: 10}(com);

        assertEq(paccs.getUserCommitment(address(this)), com);
        assertEq(paccs.getUserEtherBalance(address(this)), 10);

        // Top up again
        bytes32 com_t = keccak256(abi.encode(5678));
        paccs.topUp{value: 10}(com_t);
        assertEq(paccs.getUserCommitment(address(this)), com);
        assertEq(paccs.getUserEtherBalance(address(this)), 20);
    }

    function test_commit_to_action() public {   
        bytes32 com = keccak256(abi.encode(5678));     
        paccs.commitToAction(1234, com);
        assertEq(paccs.tx_commitments(1234), com);
    }

    function test_buyTokens() public {
        token.transfer(address(exchange), 10000);

        uint balance = token.balanceOf(address(this));
        exchange.buyTokens{value: 10}();
        assertEq(balance + 10, token.balanceOf(address(this)));
    }

    function test_orderAction() public {
        token.transfer(address(exchange), 10);
        bytes32 com = keccak256(abi.encode(1234, 5678));
        paccs.topUp{value: 10}(com);

        bytes32 com_action = keccak256(abi.encode(1234, 5678, 10));     
        paccs.commitToAction(1234, com_action);
        
        bytes32 new_com = keccak256(abi.encode(1234, 5678));
        paccs.orderAction(1234, 5678, 10, new_com);

        assertEq(token.balanceOf(address(paccs)), 10);
        assertEq(paccs.getUserEtherBalance(address(this)), 0);
        assertEq(paccs.getUserTokBalance(address(this)), 10);
    }
}
