// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Paccs.sol";
import "src/Exchange.sol";
import "src/Token.sol";
import "../src/poseidon-solidity/contracts/PoseidonT3.sol";
import "../src/poseidon-solidity/contracts/PoseidonT4.sol";

contract PaccsTest is Test {
    Token public token;
    Exchange public exchange;
    Paccs public paccs;

    using PoseidonT3 for uint256[2];
    using PoseidonT4 for uint256[3];
        
    function setUp() public {
        token = new Token("Token", "TOK");
        exchange = new Exchange(address(token));
        paccs = new Paccs(address(exchange), address(token));
    }
    
    function test_top_up() public {
        assertEq(paccs.getUserCommitment(address(this)), 0);
        assertEq(paccs.getUserEtherBalance(address(this)), 0);

        uint com = [uint256(12), uint256(34)].hash();
        paccs.topUp{value: 10}(com);

        assertEq(paccs.getUserCommitment(address(this)), com);
        assertEq(paccs.getUserEtherBalance(address(this)), 10);

        // Top up again
        uint com_t = [uint256(56), uint256(78)].hash();
        paccs.topUp{value: 10}(com_t);
        assertEq(paccs.getUserCommitment(address(this)), com);
        assertEq(paccs.getUserEtherBalance(address(this)), 20);
    }

    function test_commit_to_action() public {   
        uint com = [uint256(56), uint256(78)].hash();   
        paccs.commitToAction(12, com);
        assertEq(paccs.tx_commitments(12), com);
    }

    function test_buyTokens() public {
        token.transfer(address(exchange), 10000);

        uint balance = token.balanceOf(address(this));
        exchange.buyTokens{value: 10}();
        assertEq(balance + 10, token.balanceOf(address(this)));
    }

    function test_orderAction() public {
        token.transfer(address(exchange), 10);
        uint com = [uint256(12), uint256(34)].hash();
        paccs.topUp{value: 10}(com);

        uint com_action = [uint256(12), uint256(34), uint256(10)].hash();
        paccs.commitToAction(12, com_action);
        
        uint new_com = [uint256(56), uint256(78)].hash();
        paccs.orderAction(12, 34, 10, new_com);

        assertEq(token.balanceOf(address(paccs)), 10);
        assertEq(paccs.getUserEtherBalance(address(this)), 0);
        assertEq(paccs.getUserTokBalance(address(this)), 10);
    }
}
