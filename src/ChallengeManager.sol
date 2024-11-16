// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IChallengeManager} from "./interfaces/IChallengeManager.sol";
import {IChallenge} from "./interfaces/IChallenge.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {TimeLib} from "./libraries/TimeLib.sol";
import {Types} from "./libraries/Types.sol";
import {DripVault} from "./DripVault.sol";

contract ChallengeManager is Ownable, IChallengeManager {
    using Math for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IChallenge public challenge;

    // keccak256(abi.encode(uint256(keccak256("drip.ChallengeManager")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant ChallengeManagerStorageLocation =
        0x2e5d4946837baa00c2caecc5c5227a1c2b19f4bab88cdee66eaa65badd325500;

    modifier onlyChallenge() {
        require(msg.sender == address(challenge), ErrorsLib.NOT_AUTHORIZED);
        _;
    }

    constructor(address _challenge) Ownable(msg.sender) {
        challenge = IChallenge(_challenge);
    }

    /// @notice Returns the current epoch ID.
    /// @return ID of the current epoch.
    function getCurrentEpochId() external view returns (uint256) {
        return _getChallengeManagerStorage().currentEpoch.id;
    }

    /// @notice Returns the information of an epoch.
    /// @param epochId The ID of the epoch.
    /// @return Information of the epoch.
    function getEpochInfo(uint256 epochId) external view returns (Types.Epoch memory, Types.EpochStatus) {
        Types.ChallengeManagerStorage storage $ = _getChallengeManagerStorage();
        return ($.epochs[epochId], getEpochStatus(epochId));
    }

    /// @notice Returns the status of an epoch.
    /// @param epochId The ID of the epoch.
    /// @return Status of the epoch.
    function getEpochStatus(uint256 epochId) public view returns (Types.EpochStatus) {
        Types.Epoch memory epoch = _getChallengeManagerStorage().epochs[epochId];
        if (block.timestamp < epoch.startTimestamp) {
            return Types.EpochStatus.Pending;
        } else if (block.timestamp < epoch.endTimestamp) {
            return Types.EpochStatus.Active;
        } else if (block.timestamp < epoch.endTimestamp + 7 days) {
            return Types.EpochStatus.Ended;
        } else {
            return Types.EpochStatus.Closed;
        }
    }

    /// @notice Starts a new epoch.
    /// @param description The description.
    /// @param start The start timestamp.
    /// @param durationInDays The duration of the epoch in days.
    /// @param asset The asset to be deposited in the epoch.
    /// @return id of the new epoch.
    function startEpoch(string calldata description, uint256 start, uint16 durationInDays, address asset)
        external
        onlyOwner
        returns (uint256 id)
    {
        require(asset != address(0), ErrorsLib.ZERO_ADDRESS);
        Types.ChallengeManagerStorage storage $ = _getChallengeManagerStorage();
        require(getEpochStatus($.currentEpoch.id) >= Types.EpochStatus.Ended, ErrorsLib.INVALID_EPOCH_STATUS);

        id = $.nextEpochId;

        uint256 endTimestamp = TimeLib.addDaysToTimestamp(start, durationInDays);

        DripVault vault = new DripVault(asset, address(this));

        Types.Epoch memory epoch = Types.Epoch({
            id: id,
            description: description,
            durationInDays: durationInDays,
            startTimestamp: start,
            endTimestamp: endTimestamp,
            vault: address(vault),
            asset: asset,
            participantCount: 0,
            totalDeposits: 0
        });
        $.epochs[id] = epoch;
        $.currentEpoch = epoch;
        $.nextEpochId++;
        emit EpochStarted(id, start, endTimestamp);
    }

    function addChallengeToEpoch(uint256 epochId, Types.Challenge calldata userChallenge) external onlyChallenge {
        Types.ChallengeManagerStorage storage $ = _getChallengeManagerStorage();
        IERC20($.epochs[epochId].asset).approve($.epochs[epochId].vault, type(uint256).max);
        IERC4626($.epochs[epochId].vault).deposit(userChallenge.depositAmount, userChallenge.owner);
        DripVault($.epochs[epochId].vault).setOwnerChallengeDays(userChallenge.owner, userChallenge.durationInDays);

        $.epochChallenges[epochId].push(userChallenge.id);
        EnumerableSet.AddressSet storage participants = $.epochParticipants[epochId];
        participants.add(userChallenge.owner);
        // Update epoch info
        $.epochs[epochId].totalDeposits = IERC4626($.epochs[epochId].vault).totalAssets();
        $.epochs[epochId].participantCount = participants.length();
    }

    function getEpochChallenges(uint256 epochId) external view returns (uint256[] memory) {
        return _getChallengeManagerStorage().epochChallenges[epochId];
    }

    /// @notice Returns whether a token is whitelisted.
    /// @notice This is not used yet.
    /// @param token The address of the token to check.
    /// @return Whether the token is whitelisted.
    function isWhiteListedToken(address token) external view returns (bool) {
        return _getChallengeManagerStorage().isWhitelistedToken[token];
    }

    /// @notice DEMO ONLY
    /// @notice Sets the epoch.
    function setEpoch(uint256 epochId, Types.Epoch memory epoch) external onlyOwner {
        Types.ChallengeManagerStorage storage $ = _getChallengeManagerStorage();
        $.epochs[epochId] = epoch;
        $.currentEpoch = epoch;
        $.nextEpochId++;
    }

    /**
     * @notice Preview rewards in an epoch
     */
    function previewClaimRewards(address owner, uint256 epochId) public view returns (uint256) {
        Types.Epoch memory epoch = _getChallengeManagerStorage().epochs[epochId];
        DripVault vault = DripVault(epoch.vault);
        return vault.previewClaim(owner);
    }

    /**
     * @notice Claim rewards in an epoch
     */
    function claimRewards(address owner, uint256 epochId) external {
        require(owner == msg.sender, ErrorsLib.NOT_AUTHORIZED);
        Types.Epoch memory epoch = _getChallengeManagerStorage().epochs[epochId];
        require(getEpochStatus(epochId) == Types.EpochStatus.Ended, ErrorsLib.INVALID_EPOCH_STATUS);
        DripVault vault = DripVault(epoch.vault);
        vault.claim(owner);
    }

    /// @dev Returns the storage struct of ChallengeManager.
    function _getChallengeManagerStorage() private pure returns (Types.ChallengeManagerStorage storage $) {
        assembly {
            $.slot := ChallengeManagerStorageLocation
        }
    }
}
