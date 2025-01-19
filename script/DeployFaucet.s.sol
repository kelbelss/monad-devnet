// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Faucet} from "src/Faucet.sol";

contract DeployFaucet is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deployer address: ", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);
        Faucet faucet = new Faucet();

        // send funds to the faucet
        payable(address(faucet)).transfer(10 ether);

        vm.stopBroadcast();

        console.log("Faucet address: ", address(faucet));
    }
}
