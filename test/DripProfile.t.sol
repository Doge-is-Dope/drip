// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./helpers/SetUp.sol";

import {IDripProfile} from "../src/interfaces/IDripProfile.sol";
import {ErrorsLib} from "../src/libraries/ErrorsLib.sol";
import {Types} from "../src/libraries/Types.sol";

contract DripProfileTest is SetUp {
    function setUp() public override {
        super.setUp();

        vm.startPrank(DRIP);
        _setUpEpoch(0, block.timestamp, "Test Epoch");
        vm.stopPrank();
    }

    function testCreateProfile(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        vm.expectEmit(true, true, false, false);
        emit IDripProfile.ProfileCreated(1, USER1);
        uint256 profileId = _createProfile(USER1, handle);
        assertEq(profileId, 1);
        assertEq(profile.ownerOf(profileId), USER1);
    }

    function testCreateProfile_NotTransferable(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        vm.expectEmit(true, true, false, false);
        emit IDripProfile.ProfileCreated(1, USER1);
        uint256 profileId = _createProfile(USER1, handle);
        assertEq(profileId, 1);
        assertEq(profile.ownerOf(profileId), USER1);

        vm.prank(USER1);
        vm.expectRevert(bytes(ErrorsLib.NOT_TRANSFERABLE));
        profile.safeTransferFrom(USER1, USER2, profileId);
    }

    function testCreateProfile_InvalidHandle() public {
        vm.expectRevert(bytes(ErrorsLib.INVALID_HANDLE));
        profile.createProfile(USER1, "", _createAvatar(5));
    }

    function testCreateProfile_InvalidAvatarLength(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint32[] memory avatar = _createAvatar(4);
        vm.prank(DRIP);
        vm.expectRevert(bytes(ErrorsLib.INVALID_AVATAR_LENGTH));
        profile.createProfile(USER1, handle, avatar);
    }

    function testGetProfileById(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);
        Types.Profile memory profile = profile.getProfileById(profileId);
        assertEq(profile.owner, USER1);
        assertEq(profile.id, 1);
        assertEq(profile.handle, handle);
    }

    function testGetProfileByOwner(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        _createProfile(USER1, handle);
        Types.Profile memory profile = profile.getProfileByOwner(USER1);
        assertEq(profile.owner, USER1);
        assertEq(profile.id, 1);
        assertEq(profile.handle, handle);
    }

    function testUpdateHandle(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.prank(USER1);
        profile.updateHandle(profileId, "@user123");
        assertEq(profile.getProfileById(profileId).handle, "@user123");
    }

    function testUpdateHandle_NotOwner(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.prank(USER2);
        vm.expectRevert(bytes(ErrorsLib.NOT_OWNER));
        profile.updateHandle(profileId, "@user123");
    }

    function testCreateChallenge(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.startPrank(USER1);
        // 1. Approve Challenge to spend the token
        mockToken.approve(address(challenge), 100);
        // 2. Create the challenge
        uint256 challengeId = profile.createChallenge(profileId, "test", "test", 100, 2);
        vm.stopPrank();

        assertEq(challengeId, 0);
        assertEq(challenge.getChallenge(challengeId).owner, USER1);
        assertEq(challenge.getChallenge(challengeId).durationInDays, 2);
        assertEq(challenge.getChallenge(challengeId).depositToken, address(0)); // TODO: Fix this
        assertEq(challenge.getChallenge(challengeId).depositAmount, 100);
        assertEq(challenge.getChallenge(challengeId).epochId, 0);
        assertEq(challenge.getChallenge(challengeId).dailyCompletionTimestamps.length, 2);

        assertEq(profile.getChallenges(profileId, 0).length, 1);
        assertEq(profile.getChallenges(profileId, 0)[0].id, 0);
    }

    function testSubmitDailyCompletion(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.startPrank(USER1);
        mockToken.approve(address(challenge), 100);
        // Total 3 days
        uint256 challengeId = profile.createChallenge(profileId, "test", "test", 100, 3);

        // Day 1
        assertEq(challenge.getChallenge(challengeId).dailyCompletionTimestamps[0], 0);
        profile.submitDailyCompletion(profileId, challengeId, 0);
        assertGt(challenge.getChallenge(challengeId).dailyCompletionTimestamps[0], 0);

        // Day 2
        assertEq(challenge.getChallenge(challengeId).dailyCompletionTimestamps[1], 0);
        vm.warp(block.timestamp + 1 days);
        profile.submitDailyCompletion(profileId, challengeId, 1);
        assertGt(challenge.getChallenge(challengeId).dailyCompletionTimestamps[1], 0);
    }

    function testSubmitDailyCompletion_ExceedDuration(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.startPrank(USER1);
        mockToken.approve(address(challenge), 100);
        uint256 challengeId = profile.createChallenge(profileId, "test", "test", 100, 3);

        assertEq(challenge.getChallenge(challengeId).dailyCompletionTimestamps[0], 0);
        vm.expectRevert(bytes(ErrorsLib.EXCEED_DURATION));
        profile.submitDailyCompletion(profileId, challengeId, 3);
    }

    function testSubmitDailyCompletion_NotInTimeRange(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.startPrank(USER1);
        mockToken.approve(address(challenge), 100);
        uint256 challengeId = profile.createChallenge(profileId, "test", "test", 100, 3);
        vm.expectRevert(bytes(ErrorsLib.NOT_IN_TIME_RANGE));
        profile.submitDailyCompletion(profileId, challengeId, 1);
    }

    function testSubmitDailyCompletion_AlreadyCompleted(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        uint256 profileId = _createProfile(USER1, handle);

        vm.startPrank(USER1);
        mockToken.approve(address(challenge), 100);
        uint256 challengeId = profile.createChallenge(profileId, "test", "test", 100, 3);
        profile.submitDailyCompletion(profileId, challengeId, 0);
        vm.expectRevert(bytes(ErrorsLib.ALREADY_COMPLETED));
        profile.submitDailyCompletion(profileId, challengeId, 0);
    }
}
