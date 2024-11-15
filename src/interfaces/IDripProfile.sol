// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Types} from "../libraries/Types.sol";

/**
 * @title IDripProfile
 * @notice Interface for the DripProfile contract
 */
interface IDripProfile {
    event ProfileCreated(uint256 indexed profileId, address indexed owner);

    function createProfile(address owner, string calldata handle, uint32[] calldata avatar)
        external
        returns (uint256);

    function getProfileById(uint256 profileId) external view returns (Types.Profile memory);

    function getProfileByOwner(address owner) external view returns (Types.Profile memory);

    function updateHandle(uint256 profileId, string calldata handle) external;

    function createChallenge(
        uint256 profileId,
        string calldata name,
        string calldata description,
        uint256 depositAmount,
        uint16 durationInDays
    ) external returns (uint256);

    function getChallenges(uint256 profileId, uint256 epochId) external view returns (Types.Challenge[] memory);

    function submitDailyCompletion(uint256 profileId, uint256 challengeId, uint16 day) external;
}
