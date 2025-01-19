// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Faucet {
    address public owner;
    uint256 public cooldownPeriod = 1 days;
    uint256 public dripAmount = 1 ether;
    mapping(address => uint256) public lastRequestTime;

    event EthReceived(address indexed sender, uint256 amount);
    event EthRequested(address indexed recipient);
    event NewCooldownPeriod(uint256 indexed newCooldownPeriod);
    event NewDripAmount(uint256 indexed newDripAmount);
    event Withdraw(address owner, uint256 contractBalance);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    constructor() {
        owner = msg.sender;
    }

    function requestDMON(address recipient) external {
        require(recipient != address(0), "Invalid address");
        require(address(this).balance >= dripAmount, "Contract funds depleted");
        require(block.timestamp >= lastRequestTime[msg.sender] + cooldownPeriod, "Cooldown period has not passed");

        lastRequestTime[msg.sender] = block.timestamp;

        (bool success,) = recipient.call{value: dripAmount}("");
        require(success, "Transfer failed");

        emit EthRequested(recipient);
    }

    function updateCooldownPeriod(uint256 newCooldownPeriod) external onlyOwner {
        cooldownPeriod = newCooldownPeriod;
        emit NewCooldownPeriod(newCooldownPeriod);
    }

    function updateDripAmount(uint256 newDripAmount) external onlyOwner {
        dripAmount = newDripAmount;
        emit NewDripAmount(newDripAmount);
    }

    function withdrawFunds() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No DMON left");

        (bool success,) = owner.call{value: contractBalance}("");
        require(success, "Failed to withdraw DMON");

        emit Withdraw(owner, contractBalance);
    }
}
