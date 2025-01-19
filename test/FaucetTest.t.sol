// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Faucet} from "src/Faucet.sol";

contract TestFaucet is Test {
    Faucet public faucet;

    address recipient = vm.addr(1);

    uint256 currentTimeStamp = 90000;

    function setUp() public {
        faucet = new Faucet();
        vm.deal(address(faucet), 10 ether);
        vm.deal(address(recipient), 0 ether);
    }

    function test_Request_success() public {
        console.log(block.timestamp);

        uint256 lastRequestTime = faucet.lastRequestTime(recipient);
        console.log("lastRequestTime: ", lastRequestTime);

        uint256 cooldownPeriod = faucet.cooldownPeriod();
        console.log("cooldownPeriod: ", cooldownPeriod);

        vm.warp(currentTimeStamp);
        console.log(block.timestamp);

        vm.prank(recipient);
        faucet.requestDMON(recipient);

        assertEq(address(recipient).balance, 1 ether);
    }

    function test_Request_success_with_cooldown() public {
        vm.warp(currentTimeStamp);
        console.log(block.timestamp);

        vm.prank(recipient);
        faucet.requestDMON(recipient);

        assertEq(address(recipient).balance, 1 ether);

        vm.warp(currentTimeStamp + 1 days);
        console.log(block.timestamp);

        vm.prank(recipient);
        faucet.requestDMON(recipient);

        assertEq(address(recipient).balance, 2 ether);
    }

    function test_Request_success_with_cooldown_fail() public {
        vm.warp(currentTimeStamp);
        console.log(block.timestamp);

        vm.prank(recipient);
        faucet.requestDMON(recipient);

        assertEq(address(recipient).balance, 1 ether);

        vm.warp(currentTimeStamp + 1 days - 10 seconds);
        console.log(block.timestamp);

        vm.prank(recipient);

        vm.expectRevert("Cooldown period not passed");

        faucet.requestDMON(recipient);

        assertEq(address(recipient).balance, 1 ether);
    }
}
