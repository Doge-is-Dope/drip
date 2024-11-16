// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library Types {
    /* ENUMS */

    /// @notice Represents the current state of an epoch
    enum EpochStatus {
        // 0 - The epoch has not started yet.
        Pending,
        // 1 - The epoch is active and users can create challenges.
        Active,
        // 2 - The Epoch has ended. Users can no longer create challenges and have a 7-day window to claim rewards.
        Ended,
        // 3 - The epoch is fully closed. No more actions can be performed.
        Closed
    }

    /* STRUCTS */

    /// @notice User profile
    struct Profile {
        uint256 id;
        address owner;
        string handle;
        uint32[] avatar; // Avatar: [0-background, 1-body, 2-accessory, 3-head, 4-glasses]
    }

    /// @notice Epoch details
    struct Epoch {
        uint256 id;
        uint256 startTimestamp;
        uint256 endTimestamp;
        // Number of participants in the epoch
        uint256 participantCount;
        uint256 totalDeposits;
        // The vault to be used for the epoch
        address vault;
        // The asset to be deposited in the epoch
        address asset;
        uint16 durationInDays;
        string description;
    }

    /// @notice Challenge details
    struct Challenge {
        uint256 id;
        uint256 epochId;
        uint256 startTime;
        uint256 endTime;
        uint256 depositAmount;
        address owner;
        address depositToken;
        uint16 durationInDays;
        string title;
        string description;
        uint256[] dailyCompletionTimestamps;
    }

    /// @notice Parameters for creating a challenge
    struct CreateChallengeParams {
        address owner;
        uint256 depositAmount;
        uint256 epochId;
        uint16 durationInDays;
        string title;
        string description;
    }

    /// @notice Challenge manager storage
    struct ChallengeManagerStorage {
        // Next epoch ID
        uint256 nextEpochId;
        // Current epoch
        Types.Epoch currentEpoch;
        // Epoch ID => Epoch
        mapping(uint256 => Epoch) epochs;
        // Epoch ID => challenge IDs
        mapping(uint256 => uint256[]) epochChallenges;
        // Epoch ID => participants
        mapping(uint256 => EnumerableSet.AddressSet) epochParticipants;
        // Token address => is whitelisted
        mapping(address => bool) isWhitelistedToken;
    }
}
