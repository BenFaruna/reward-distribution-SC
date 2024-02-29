// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IRewardDistribution {
    function addUserEntry(address _user) external;
}

contract RewardGame {
    address rewardAddress;
    address owner;

    mapping(address => uint256) public userWins;

    uint256 lastHash;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _rewardAddr) {
        rewardAddress = _rewardAddr;
        owner = msg.sender;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            userWins[msg.sender]++;
            _updateUserEntry();
            return true;
        }
        return false;
    }

    function _updateUserEntry() internal {
        IRewardDistribution _rewardContract = IRewardDistribution(rewardAddress);

        if (userWins[msg.sender] > 2) {
            _rewardContract.addUserEntry(msg.sender);
        }
    }

    function updateRewardAddress(address _newRewardAddress) public {
        require(msg.sender == owner, "Not owner");
        rewardAddress = _newRewardAddress;
    }
}
