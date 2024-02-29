// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Errors {
    error ZERO_ADDRESS_CALL();
    error ONLY_ADMIN_HAVE_ACCESS();
    error ONLY_MODEARTOR_AND_ADMIN_HAVE_ACCESS();
    error UNREGISTERED_ADDRESS();
    error NOT_A_MODERATOR();
    error USER_ALREADY_REGISTERED();
    error CANNOT_JOIN_COMMUNITY_TWICE();
    error NO_USER_POST();
    error ONLY_OWNER();
    error NO_SOCIAL_MEDIA_CREATED();
    error INVALID_COMMUNITY_ID();
    error ONLY_COMMUNITY_MEMBER();
    error CANNOT_ASSIGN_MODERATOR_TWICE();
}