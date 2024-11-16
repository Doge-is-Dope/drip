// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Types} from "../libraries/Types.sol";

/**
 * @title IChallengeManager
 * @notice Interface for the ChallengeManager contract
 */
interface IChallengeManager {
    event EpochStarted(uint256 id, uint256 startTimestamp, uint256 endTimestamp);

    /**
     * @dev Returns the current epoch ID
     */
    function getCurrentEpochId() external view returns (uint256);

    /**
     * @dev Returns the epoch info for a given epoch ID
     */
    function getEpochInfo(uint256 epochId) external view returns (Types.Epoch memory, Types.EpochStatus);

    /**
     * @dev Returns the status of an epoch
     */
    function getEpochStatus(uint256 epochId) external view returns (Types.EpochStatus);

    /**
     * @dev Starts a new epoch
     */
    function startEpoch(string calldata description, uint256 start, uint16 durationInDays, address depositToken)
        external
        returns (uint256);

    /**
     * @dev Adds a challenge to an epoch
     */
    function addChallengeToEpoch(uint256 epochId, Types.Challenge calldata challenge) external;

    /**
     * @dev Returns the challenges for an epoch
     */
    function getEpochChallenges(uint256 epochId) external view returns (uint256[] memory);

    /**
     * @dev Returns if a token is whitelisted for depositing when creating a challenge
     */
    function isWhiteListedToken(address token) external view returns (bool isWhitelisted);

    /**
     * @dev Preview rewards in an epoch
     */
    function previewClaimRewards(address owner, uint256 epochId) external view returns (uint256);

    /**
     * @dev Claim rewards in an epoch
     */
    function claimRewards(address owner, uint256 epochId) external;
}
