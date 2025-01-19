// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

interface IFaucet {
    function disburse(address recipient, uint256 amount) external;

    function lastRequestTime(address user) external view returns (uint256);

    function cooldownPeriod() external view returns (uint256);
}

contract DMONMouchDrops is Script {
    address constant FAUCET = 0xa5600c59440a629E61b9C5aBaF5016B3fd844b40;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address: ", deployer);
        console.log("Deployer balance before: ", deployer.balance);

        uint256 amount = 10e18;
        uint256 lastRequestTime = IFaucet(FAUCET).lastRequestTime(deployer);
        uint256 cooldownTime = IFaucet(FAUCET).cooldownPeriod();

        if (lastRequestTime + cooldownTime > block.timestamp) {
            uint256 timeLeft = (lastRequestTime + cooldownTime) - block.timestamp;
            console.log("Cooldown time not passed yet, wait ", timeLeft, " seconds");
            return;
        }

        vm.startBroadcast(deployerPrivateKey);
        IFaucet(FAUCET).disburse(deployer, amount);
        vm.stopBroadcast();

        console.log("Deployer balance after: ", deployer.balance);
    }
}
