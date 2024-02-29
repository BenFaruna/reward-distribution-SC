// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {

    address public owner;

    constructor () ERC20("RewardToken", "RT") {
        owner = msg.sender;
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
}
