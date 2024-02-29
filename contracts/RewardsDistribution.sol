// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "./errors/Errors.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract RewardsDistribution {
    address public rewardsToken;
    address public owner;
    address public gameAddress;

    uint256 public totalReward;
    uint256 public entryToDistribution;

    mapping(address => bool) public isRegistered;
    mapping(address => bool) public isEligible;
    mapping(address => uint256) public userEntries;

    address[] public eligibleUsers;

    bool public isActive;

    event EligibleUserAdded(address userAddress, uint256 entryNo);
    event TotalRewardUpdated(uint256 _from, uint256 _to);
    event RewardSent(address indexed _user, uint256 _amount);
    event UpdateGameAddress(address _newAddress);

    constructor(address _rewardsToken, uint256 _amountToDistribution) {
        owner = msg.sender;
        rewardsToken = _rewardsToken;
        isRegistered[msg.sender] = true;
        entryToDistribution = _amountToDistribution;
        isActive = true;
    }

    function registerUser() public {
        if (msg.sender == address(0)) {
            revert Errors.ADDRESS_ZERO_CALL();
        }

        if (isRegistered[msg.sender]) {
            revert Errors.USER_ALREADY_REGISTERED();
        }

        isRegistered[msg.sender] = true;
    }

    function addUserEntry(address _user) public {
        if (msg.sender == address(0)) {
            revert Errors.ADDRESS_ZERO_CALL();
        }

        if (msg.sender != gameAddress) {
            revert Errors.NOT_GAME_ADDRESS();
        }

        if (!isRegistered[_user]) {
            revert Errors.USER_NOT_REGISTERED();
        }

        if ((eligibleUsers.length < entryToDistribution) && isActive) {
            if (!isEligible[_user]) {
                isEligible[_user] = true;
                eligibleUsers.push(_user);
                userEntries[_user] = 1;
                emit EligibleUserAdded(_user, eligibleUsers.length);
            }

            userEntries[_user] = userEntries[_user] + 1;
        }
    }

    function setGameAddress(address _gameAddress) public {
        if (msg.sender != owner) {
            revert Errors.NOT_OWNER();
        }

        gameAddress = _gameAddress;

        emit UpdateGameAddress(_gameAddress);
    }

    function changeTotalReward(uint256 _newTotalReward) public {
        if (msg.sender != owner) {
            revert Errors.NOT_OWNER();
        }

        uint256 _oldReward = totalReward;
        totalReward = _newTotalReward;

        emit TotalRewardUpdated(_oldReward, _newTotalReward);
    }

    function changeEntryToDistribution(uint256 _newEntry) public {
        if (msg.sender != owner) {
            revert Errors.NOT_OWNER();
        }

        uint256 _oldEntry = entryToDistribution;
        entryToDistribution = _newEntry;

        emit TotalRewardUpdated(_oldEntry, _newEntry);
    }

    // TODO: change to internal
    function _calculateRewardPerUser() public view returns (uint256 _reward) {
        if (entryToDistribution == 0) {
            revert();
        }
        _reward = uint256(totalReward / entryToDistribution);
    }

    function distributeRewards() public {
        if (msg.sender != owner) {
            revert Errors.NOT_OWNER();
        }

        if ((eligibleUsers.length == entryToDistribution) && isActive) {
            isActive = false;
            uint256 _reward = _calculateRewardPerUser();
            _shareRewards(_reward);
        } else {
            revert Errors.TOTAL_ENTRIES_NOT_REACHED();
        }
    }

    function _shareRewards(uint256 _reward) internal {
        IERC20 _rewardContract = IERC20(rewardsToken);

        for (uint256 i = 0; i < eligibleUsers.length; i++) {
            require(_rewardContract.transfer(eligibleUsers[i], _reward), "could not send transaction");

            emit RewardSent(eligibleUsers[i], _reward);
        }
    }
}
