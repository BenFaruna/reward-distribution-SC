// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Errors {
    error ADDRESS_ZERO_CALL();
    error USER_ALREADY_REGISTERED();
    error USER_NOT_REGISTERED();
    error NOT_GAME_ADDRESS();
    error NOT_OWNER();
    error TOTAL_ENTRIES_NOT_REACHED();
}