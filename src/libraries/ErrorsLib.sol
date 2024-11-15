// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title ErrorsLib
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @dev Thrown when the address is zero.
    string internal constant ZERO_ADDRESS = "zero address";
    /// @dev Thrown when the caller is not the owner of the token.
    string internal constant NOT_OWNER = "not owner";
    /// @dev Thrown when the caller is not from the authorized address.
    string internal constant NOT_AUTHORIZED = "not authorized";
    /// @dev Thrown when the profile is attempt to be transferred.
    string internal constant NOT_TRANSFERABLE = "not transferable";
    /// @dev Thrown when the profile contract is already set.
    string internal constant PROFILE_CONTRACT_ALREADY_SET = "profile contract already set";
    /// @dev Thrown when the profile is not exists.
    string internal constant PROFILE_NOT_EXISTS = "profile not exists";
    /// @dev Thrown when the epoch status is invalid.
    string internal constant INVALID_EPOCH_STATUS = "invalid epoch status";
    /// @dev Thrown when the avatar length is invalid.
    string internal constant INVALID_AVATAR_LENGTH = "invalid avatar length";
    /// @dev Thrown when the handle is invalid.
    string internal constant INVALID_HANDLE = "invalid handle";
    /// @dev Thrown when the duration is invalid.
    string internal constant INVALID_DURATION = "invalid duration";
    /// @dev Thrown when the day exceeds the duration.
    string internal constant EXCEED_DURATION = "exceed duration";
    /// @dev Thrown when the day is not in the time range.
    string internal constant NOT_IN_TIME_RANGE = "not in time range";
    /// @dev Thrown when the day is already completed.
    string internal constant ALREADY_COMPLETED = "already completed";
}
