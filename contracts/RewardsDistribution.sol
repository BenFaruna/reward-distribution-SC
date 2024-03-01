// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import "./errors/Errors.sol";
import "./VRFv2Consumer.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract RewardsDistribution is VRFv2Consumer {
    address public rewardsToken;
    address _owner;
    address public gameAddress;

    uint32 public entryToDistribution;
    uint256 public totalReward;

    mapping(address => bool) public isRegistered;
    mapping(address => bool) public isEligible;
    mapping(address => uint256) public userEntries;

    address[] public eligibleUsers;

    bool public isActive;

    event EligibleUserAdded(address userAddress, uint256 entryNo);
    event TotalRewardUpdated(uint256 _from, uint256 _to);
    event RewardSent(uint256 userNumber, address indexed _user, uint256 _amount);
    event UpdateGameAddress(address _newAddress);

    constructor(address _rewardsToken, uint32 _amountToDistribution, uint64 subscriptionID) VRFv2Consumer (subscriptionID) {
        _owner = msg.sender;
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

        if (eligibleUsers.length == entryToDistribution) {
            requestRandomWords(entryToDistribution);
        }
    }

    function setGameAddress(address _gameAddress) public {
        if (msg.sender != _owner) {
            revert Errors.NOT_OWNER();
        }

        gameAddress = _gameAddress;

        emit UpdateGameAddress(_gameAddress);
    }

    function changeTotalReward(uint256 _newTotalReward) public {
        if (msg.sender != _owner) {
            revert Errors.NOT_OWNER();
        }

        uint256 _oldReward = totalReward;
        totalReward = _newTotalReward;

        emit TotalRewardUpdated(_oldReward, _newTotalReward);
    }

    function changeEntryToDistribution(uint32 _newEntry) public {
        if (msg.sender != _owner) {
            revert Errors.NOT_OWNER();
        }

        uint256 _oldEntry = entryToDistribution;
        entryToDistribution = _newEntry;

        emit TotalRewardUpdated(_oldEntry, _newEntry);
    }

    function _calculateRewardPerUser() internal view returns (uint256 _reward) {
        if (entryToDistribution == 0) {
            revert();
        }
        _reward = uint256(totalReward / entryToDistribution);
    }

    function distributeRewards() public {
        if (msg.sender != _owner) {
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

        (bool _fullfiled, uint256[] memory _randomNumbers) = getRequestStatus(lastRequestId);

        if (!_fullfiled) {
            revert("Random numbers not generated");
        }

        for (uint256 i = 0; i < eligibleUsers.length; i++) {
            uint256 userNumber = (_randomNumbers[i] % entryToDistribution) + 1;
            require(_rewardContract.transfer(eligibleUsers[userNumber], _reward), "could not send transaction");

            emit RewardSent(userNumber, eligibleUsers[userNumber], _reward);
        }
    }
}
