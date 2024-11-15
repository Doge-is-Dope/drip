// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Types} from "../libraries/Types.sol";

/**
 * @title IChallenge
 * @notice Interface for the Challenge contract
 */
interface IChallenge {
    event ChallengeCreated(uint256 indexed tokenId, address indexed owner);

    event DailyCompletionSubmitted(uint256 indexed tokenId, uint256 indexed day);

    event ChallengeCompleted(uint256 indexed tokenId, address indexed learner);

    event RewardClaimed(uint256 indexed tokenId, address indexed learner, uint256 amount);

    /// @notice Creates a challenge
    function createChallenge(Types.CreateChallengeParams calldata params) external returns (uint256);

    /// @notice Returns the challenge for a given ID
    function getChallenge(uint256 challengeId) external view returns (Types.Challenge memory);

    /// @notice Submits a daily completion
    function submitDailyCompletion(address owner, uint256 tokenId, uint16 day) external;

    /// @notice Returns the challenges for an epoch
    function getChallengesByEpoch(uint256 epochId) external view returns (Types.Challenge[] memory);
}
