// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "../lib/solmate/src/utils/SafeTransferLib.sol";
import {ChallengeManager} from "./ChallengeManager.sol";
import {IChallengeManager} from "./interfaces/IChallengeManager.sol";
import {IChallenge} from "./interfaces/IChallenge.sol";
import {Types} from "./libraries/Types.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {TimeLib} from "./libraries/TimeLib.sol";
import {DripVault} from "./DripVault.sol";

contract Challenge is ERC721, IChallenge {
    using Math for uint256;
    using SafeTransferLib for ERC20;

    uint256 private _tokenId; // Token ID for each challenge; starts at 0
    address public profileContract;
    address public managerContract;

    mapping(uint256 => Types.Challenge) private _challenges; // tokenId => challenge

    constructor() ERC721("Drip Challenge", "DCH") {}

    modifier onlyProfile(address profileOwner) {
        // Only the profile contract or the owner can call this function
        require(msg.sender == profileContract || msg.sender == profileOwner, ErrorsLib.NOT_OWNER);
        _;
    }

    function setContracts(address _profileContract, address _managerContract) external {
        // Can only be set once
        require(profileContract == address(0), ErrorsLib.PROFILE_CONTRACT_ALREADY_SET);
        profileContract = _profileContract;
        managerContract = _managerContract;
    }

    function createChallenge(Types.CreateChallengeParams calldata params)
        external
        onlyProfile(params.owner)
        returns (uint256 challengeId)
    {
        require(params.durationInDays <= 365, ErrorsLib.INVALID_DURATION);

        uint256 epochId = IChallengeManager(managerContract).getCurrentEpochId();
        (Types.Epoch memory epoch, Types.EpochStatus status) = IChallengeManager(managerContract).getEpochInfo(epochId);
        require(status == Types.EpochStatus.Active, ErrorsLib.INVALID_EPOCH_STATUS);

        // Transfer epoch asset from user to challenge manager
        ERC20(epoch.asset).safeTransferFrom(params.owner, managerContract, params.depositAmount);

        // Calculate duration and end time
        uint256 startTime = block.timestamp;
        uint256 endTime = TimeLib.addDaysToTimestamp(startTime, params.durationInDays);

        Types.Challenge storage challenge = _challenges[_tokenId];
        challenge.id = _tokenId;
        challenge.title = params.title;
        challenge.description = params.description;
        challenge.owner = params.owner;
        challenge.startTime = startTime;
        challenge.endTime = endTime;
        challenge.depositAmount = params.depositAmount;
        challenge.depositToken = address(0); // TODO: Get from epoch
        challenge.durationInDays = params.durationInDays;
        challenge.epochId = params.epochId;
        challenge.dailyCompletionTimestamps = new uint256[](params.durationInDays);

        // Mint and emit the challenge event
        _safeMint(params.owner, _tokenId);
        emit ChallengeCreated(_tokenId, params.owner);

        // Add the challenge to the epoch
        IChallengeManager(managerContract).addChallengeToEpoch(params.epochId, challenge);

        // Return challenge ID and increment the token counter
        challengeId = _tokenId;
        ++_tokenId;
    }

    function getChallenge(uint256 challengeId) external view returns (Types.Challenge memory) {
        return _challenges[challengeId];
    }

    function getChallengesByEpoch(uint256 epochId) external view returns (Types.Challenge[] memory) {
        uint256[] memory challengeIds = IChallengeManager(managerContract).getEpochChallenges(epochId);
        uint256 length = challengeIds.length;
        Types.Challenge[] memory challenges = new Types.Challenge[](length);

        for (uint256 i = 0; i < length;) {
            challenges[i] = _challenges[challengeIds[i]];
            unchecked {
                ++i;
            }
        }
        return challenges;
    }

    function submitDailyCompletion(address owner, uint256 tokenId, uint16 day) external onlyProfile(owner) {
        Types.Challenge storage challenge = _challenges[tokenId];
        require(day < challenge.durationInDays, ErrorsLib.EXCEED_DURATION);
        require(challenge.dailyCompletionTimestamps[day] == 0, ErrorsLib.ALREADY_COMPLETED);

        uint256 dayStartTime = TimeLib.addDaysToTimestamp(challenge.startTime, day);
        uint256 dayEndTime = TimeLib.addDaysToTimestamp(dayStartTime, 1);

        require(block.timestamp >= dayStartTime && block.timestamp <= dayEndTime, ErrorsLib.NOT_IN_TIME_RANGE);

        challenge.dailyCompletionTimestamps[day] = block.timestamp;

        // Update vault
        (Types.Epoch memory epoch,) = IChallengeManager(managerContract).getEpochInfo(challenge.epochId);
        DripVault vault = DripVault(epoch.vault);
        vault.submitDailyCompletion(owner, challenge.dailyCompletionTimestamps);

        emit DailyCompletionSubmitted(tokenId, day);
    }

    /// @dev Only for demo
    function createChallengeDemo(Types.CreateChallengeParams calldata params, uint256 epochId, uint256 startTime)
        external
        onlyProfile(params.owner)
        returns (uint256 challengeId)
    {
        (Types.Epoch memory epoch,) = IChallengeManager(managerContract).getEpochInfo(epochId);

        // Transfer epoch asset from user to challenge manager
        ERC20(epoch.asset).safeTransferFrom(params.owner, managerContract, params.depositAmount);

        // Calculate duration and end time
        uint256 endTime = TimeLib.addDaysToTimestamp(startTime, params.durationInDays);

        Types.Challenge storage challenge = _challenges[_tokenId];
        challenge.id = _tokenId;
        challenge.title = params.title;
        challenge.description = params.description;
        challenge.owner = params.owner;
        challenge.startTime = startTime;
        challenge.endTime = endTime;
        challenge.depositAmount = params.depositAmount;
        challenge.depositToken = address(0); // TODO: Get from epoch
        challenge.durationInDays = params.durationInDays;
        challenge.epochId = params.epochId;
        challenge.dailyCompletionTimestamps = new uint256[](params.durationInDays);

        // Mint and emit the challenge event
        _safeMint(params.owner, _tokenId);
        emit ChallengeCreated(_tokenId, params.owner);

        // Add the challenge to the epoch
        ChallengeManager(managerContract).addChallengeToEpochDemo(params.epochId, challenge);

        // Return challenge ID and increment the token counter
        challengeId = _tokenId;
        ++_tokenId;
    }

    function setDailyCompletionDemo(address owner, uint256 tokenId, uint256[] memory timestamps)
        external
        onlyProfile(owner)
    {
        Types.Challenge storage challenge = _challenges[tokenId];

        challenge.dailyCompletionTimestamps = timestamps;

        // Update vault
        (Types.Epoch memory epoch,) = IChallengeManager(managerContract).getEpochInfo(challenge.epochId);
        DripVault vault = DripVault(epoch.vault);
        vault.submitDailyCompletion(owner, challenge.dailyCompletionTimestamps);
    }
}
