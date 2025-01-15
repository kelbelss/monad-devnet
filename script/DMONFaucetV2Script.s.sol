// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

interface IFaucet {
    function requestTokens(address recipient) external;

    function lastRequestTime(address user) external view returns (uint256);

    function cooldownTime() external view returns (uint256);
}

contract DMONFaucetScript is Script {
    address constant FAUCET = 0xA66a64204aA680b6B9fdef0B0AC685744ACcCb10;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deployer address: ", deployer);
        console.log("Deployer balance before: ", deployer.balance);

        uint256 lastRequestTime = IFaucet(FAUCET).lastRequestTime(deployer);
        uint256 cooldownTime = IFaucet(FAUCET).cooldownTime();

        if (lastRequestTime + cooldownTime > block.timestamp) {
            uint256 timeLeft = (lastRequestTime + cooldownTime) - block.timestamp;
            console.log("Cooldown time not passed yet, wait ", timeLeft, " seconds");
            return;
        }

        vm.startBroadcast(deployerPrivateKey);
        IFaucet(FAUCET).requestTokens(deployer);
        vm.stopBroadcast();

        console.log("Deployer balance after: ", deployer.balance);
    }
}
