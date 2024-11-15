// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {Types} from "./libraries/Types.sol";
import {IDripProfile} from "./interfaces/IDripProfile.sol";
import {Challenge} from "./Challenge.sol";
import {ChallengeManager} from "./ChallengeManager.sol";

contract DripProfile is ERC721, IDripProfile {
    uint256 private _nextProfileId; // Token ID for each profile; starts at 1

    mapping(address => uint256) private _ownerToProfileId; // Maps address to profileId
    mapping(uint256 => Types.Profile) private _profileIdToProfile; // Maps profileId to Profile struct
    mapping(uint256 => mapping(uint256 => uint256[])) private _profileIdToEpochIdToChallengeIds; // Maps profileId to epoch Id to associated challenges

    Challenge private challenge;
    ChallengeManager private challengeManager;

    constructor(address challengeAddress, address challengeManagerAddress) ERC721("Drip Profile", "DP") {
        challenge = Challenge(challengeAddress);
        challengeManager = ChallengeManager(challengeManagerAddress);
        challenge.setContracts(address(this), challengeManagerAddress);
    }

    /**
     * @dev Modifier to check that the caller is the owner of the profile.
     * @param profileId The ID of the profile to check ownership.
     */
    modifier onlyProfileOwner(uint256 profileId) {
        require(ownerOf(profileId) == msg.sender, ErrorsLib.NOT_OWNER);
        _;
    }

    /**
     * @dev Creates a new profile for the caller.
     * @param owner The owner of the profile
     * @param handle The user handle
     * @param avatar The user avatar data
     * @return profileId The ID of the created profile.
     */
    function createProfile(address owner, string calldata handle, uint32[] calldata avatar)
        external
        returns (uint256)
    {
        require(owner != address(0), ErrorsLib.ZERO_ADDRESS);
        require(bytes(handle).length > 0, ErrorsLib.INVALID_HANDLE);
        require(avatar.length == 5, ErrorsLib.INVALID_AVATAR_LENGTH);

        uint256 profileId = ++_nextProfileId;
        _safeMint(owner, profileId);
        _ownerToProfileId[owner] = profileId;
        _profileIdToProfile[profileId] = Types.Profile(profileId, owner, handle, avatar);
        emit ProfileCreated(profileId, owner);
        return profileId;
    }

    /**
     * @dev Retrieves profile data by profile ID.
     * @param profileId The ID of the profile to retrieve.
     * @return profile The profile data
     */
    function getProfileById(uint256 profileId) external view returns (Types.Profile memory) {
        return _profileIdToProfile[profileId];
    }

    /**
     * @dev Retrieves profile ID by owner.
     * @param owner The owner of the profile
     * @return profileId The ID of the profile
     */
    function getProfileByOwner(address owner) external view returns (Types.Profile memory) {
        uint256 profileId = _ownerToProfileId[owner];
        require(profileId != 0, ErrorsLib.PROFILE_NOT_EXISTS);
        return _profileIdToProfile[profileId];
    }

    /**
     * @dev Updates the user handle of an existing profile.
     * @param profileId The ID of the profile to update.
     * @param handle The new handle of the profile
     */
    function updateHandle(uint256 profileId, string calldata handle) external onlyProfileOwner(profileId) {
        require(profileId != 0, ErrorsLib.PROFILE_NOT_EXISTS);
        require(bytes(handle).length > 0, ErrorsLib.INVALID_HANDLE);
        _profileIdToProfile[profileId].handle = handle;
    }

    /**
     * @dev Creates a new challenge associated with a profile.
     * @param profileId The ID of the profile to associate with the challenge.
     * @param depositAmount The amount to be deposited in the challenge.
     * @param durationInDays The duration of the challenge in days.
     * @return challengeId The ID of the created challenge.
     */
    function createChallenge(
        uint256 profileId,
        string calldata name,
        string calldata description,
        uint256 depositAmount,
        uint16 durationInDays
    ) external onlyProfileOwner(profileId) returns (uint256) {
        require(profileId != 0, ErrorsLib.PROFILE_NOT_EXISTS);

        uint256 epochId = challengeManager.getCurrentEpochId();
        Types.CreateChallengeParams memory params =
            Types.CreateChallengeParams(msg.sender, depositAmount, epochId, durationInDays, name, description);
        uint256 challengeId = challenge.createChallenge(params);
        _profileIdToEpochIdToChallengeIds[profileId][epochId].push(challengeId);
        return challengeId;
    }

    /**
     * @dev Retrieves the challenges associated with a profile.
     * @param profileId The ID of the profile to retrieve the challenges.
     * @return challenges The challenges associated with the profile.
     */
    function getChallenges(uint256 profileId, uint256 epochId) external view returns (Types.Challenge[] memory) {
        require(profileId != 0, ErrorsLib.PROFILE_NOT_EXISTS);

        uint256[] storage challengeIds = _profileIdToEpochIdToChallengeIds[profileId][epochId];
        uint256 challengesLength = challengeIds.length;

        Types.Challenge[] memory challenges = new Types.Challenge[](challengesLength);

        for (uint256 i = 0; i < challengesLength;) {
            challenges[i] = challenge.getChallenge(challengeIds[i]);

            unchecked {
                i++;
            }
        }
        return challenges;
    }

    /**
     * @dev Submits a daily completion for a challenge associated with a profile.
     * @param profileId The ID of the profile associated with the challenge.
     * @param challengeId The ID of the challenge to submit the daily completion.
     * @param day The day to submit the completion for.
     */
    function submitDailyCompletion(uint256 profileId, uint256 challengeId, uint16 day)
        external
        onlyProfileOwner(profileId)
    {
        challenge.submitDailyCompletion(msg.sender, challengeId, day);
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = super._update(to, tokenId, auth);
        require(from == address(0), ErrorsLib.NOT_TRANSFERABLE);
        return from;
    }
}
