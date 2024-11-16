// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./helpers/SetUp.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {DripVault} from "../src/DripVault.sol";
import {ErrorsLib} from "../src/libraries/ErrorsLib.sol";
import {Types} from "../src/libraries/Types.sol";

contract ChallengeManagerTest is SetUp {
    function testStartEpoch() public {
        // Start first epoch
        uint256 startTimestamp = block.timestamp;
        vm.prank(DRIP);
        uint256 epochId1 = challengeManager.startEpoch("test1", startTimestamp, 3, address(mockToken));
        assertEq(epochId1, 0);
        assertEq(challengeManager.getCurrentEpochId(), 0);

        (Types.Epoch memory epoch1, Types.EpochStatus status1) = challengeManager.getEpochInfo(0);
        assertEq(epoch1.durationInDays, 3);
        assertEq(epoch1.startTimestamp, startTimestamp);
        assertEq(epoch1.endTimestamp, startTimestamp + 3 days);
        assertEq(uint256(status1), uint256(Types.EpochStatus.Active));

        // End first epoch
        uint256 timeElapsed = startTimestamp + 3 days;
        vm.warp(timeElapsed);
        assertEq(uint256(challengeManager.getEpochStatus(0)), uint256(Types.EpochStatus.Ended), "Epoch1 ended");

        // Start next epoch
        vm.prank(DRIP);
        uint256 epochId2 = challengeManager.startEpoch("test2", timeElapsed, 3, address(mockToken));
        assertEq(epochId2, 1);
        assertEq(challengeManager.getCurrentEpochId(), 1);

        (Types.Epoch memory epoch2, Types.EpochStatus status2) = challengeManager.getEpochInfo(1);
        assertEq(epoch2.durationInDays, 3);
        assertEq(epoch2.startTimestamp, timeElapsed);
        assertEq(epoch2.endTimestamp, timeElapsed + 3 days);
        assertEq(uint256(status2), uint256(Types.EpochStatus.Active), "Epoch2 is active");
    }

    function testStartEpoch_NotOwner() public {
        vm.expectRevert();
        vm.prank(USER1);
        challengeManager.startEpoch("test", block.timestamp, 7, address(mockToken));
    }

    function testStartEpoch_InvalidStatus() public {
        vm.prank(DRIP);
        challengeManager.startEpoch("test1", block.timestamp, 7, address(mockToken));

        vm.expectRevert(bytes(ErrorsLib.INVALID_EPOCH_STATUS));
        vm.prank(DRIP);
        challengeManager.startEpoch("test2", block.timestamp, 7, address(mockToken));
    }

    function testEpochStatus() public {
        uint256 current = block.timestamp;
        vm.prank(DRIP);
        challengeManager.startEpoch("test", current + 30 seconds, 3, address(mockToken));

        uint256 status = uint256(challengeManager.getEpochStatus(0));
        assertEq(status, uint256(Types.EpochStatus.Pending));

        vm.warp(current + 30 seconds);
        status = uint256(challengeManager.getEpochStatus(0));
        assertEq(status, uint256(Types.EpochStatus.Active));

        vm.warp(current + 3 days + 30 seconds);
        status = uint256(challengeManager.getEpochStatus(0));
        assertEq(status, uint256(Types.EpochStatus.Ended));

        vm.warp(current + 7 days + 3 days + 30 seconds);
        status = uint256(challengeManager.getEpochStatus(0));
        assertEq(status, uint256(Types.EpochStatus.Closed));
    }

    function testPreviewRewards() public {
        uint256 epochId = _createDummyEpoch();
        (Types.Epoch memory epoch,) = challengeManager.getEpochInfo(epochId);
        (uint256 profileId1, uint256 profileId2) = _createDummyProfiles();
        DripVault vault = DripVault(epoch.vault);

        // User1 creates a challenge by depositing 10 tokens
        vm.startPrank(USER1);
        deal(address(mockToken), USER1, 100);
        _createDummyChallenge(profileId1, 10, 5);
        assertEq(vault.ownerDeposits(USER1), 10, "User1 deposited 10 tokens");
        assertEq(IERC20(address(vault)).balanceOf(USER1), 10, "User1 got 10 DRIP-VLT");
        assertEq(IERC20(mockToken).balanceOf(USER1), 90, "User1 has 90 tokens left");
        vm.stopPrank();

        // User2 creates a challenge by depositing 15 tokens
        vm.startPrank(USER2);
        deal(address(mockToken), USER2, 100);
        _createDummyChallenge(profileId2, 15, 3);
        assertEq(vault.ownerDeposits(USER2), 15, "User2 deposited 15 tokens");
        assertEq(IERC20(address(vault)).balanceOf(USER2), 15, "User2 got 15 DRIP-VLT");
        assertEq(IERC20(mockToken).balanceOf(USER2), 85, "User2 has 85 tokens left");
        vm.stopPrank();

        // Total deposits
        assertEq(vault.totalAssets(), 25, "Total deposits are 25 tokens");

        _submitDummyDailyCompletion();
        vm.warp(432002);

        // Calculate claimable rewards
        vault.calculateOwnersClaimable();

        vm.startPrank(USER1);

        assertEq(challengeManager.previewClaimRewards(USER1, epochId), 7, "User1 claimable rewards");
        challengeManager.claimRewards(USER1, epochId);
        assertEq(IERC20(address(vault)).balanceOf(USER1), 0, "User1 has 0 DRIP-VLT");
        assertEq(IERC20(mockToken).balanceOf(USER1), 97, "User1 has 97 tokens");
        vm.stopPrank();

        vm.startPrank(USER2);
        assertEq(challengeManager.previewClaimRewards(USER2, epochId), 17, "User2 claimable rewards");
        challengeManager.claimRewards(USER2, epochId);
        assertEq(IERC20(address(vault)).balanceOf(USER2), 0, "User2 has 0 DRIP-VLT");
        assertEq(IERC20(mockToken).balanceOf(USER2), 102, "User2 has 102 tokens");
        vm.stopPrank();
    }

    function testClaimRewards_EpochNotEnded() public {
        uint256 epochId = _createDummyEpoch();

        vm.prank(USER1);
        vm.expectRevert(bytes(ErrorsLib.INVALID_EPOCH_STATUS));
        challengeManager.claimRewards(USER1, epochId);
    }

    function _createDummyChallenge(uint256 profileId, uint256 amount, uint16 durationDays) private returns (uint256) {
        mockToken.approve(address(challenge), amount);
        return profile.createChallenge(profileId, "title", "desc", amount, durationDays);
    }

    function _submitDummyDailyCompletion() private {
        uint256 user1ChallengeId = 0;
        uint256 user2ChallengeId = 1;

        // 1st day (1 - 86401)
        vm.prank(USER1);
        challenge.submitDailyCompletion(USER1, user1ChallengeId, 0);
        vm.prank(USER2);
        challenge.submitDailyCompletion(USER2, user2ChallengeId, 0);

        // 2nd day (86401 - 172801)
        vm.warp(86401);
        vm.prank(USER1);
        challenge.submitDailyCompletion(USER1, user1ChallengeId, 1);
        vm.prank(USER2);
        challenge.submitDailyCompletion(USER2, user2ChallengeId, 1);

        // 3rd day (172801 - 259201)
        vm.warp(172801);
        vm.prank(USER2);
        challenge.submitDailyCompletion(USER2, user2ChallengeId, 2);

        // 4th day (259201 - 345601)
        // No submission

        // 5th day (345601 - 432001)
        vm.warp(345601);
        vm.prank(USER1);
        challenge.submitDailyCompletion(USER1, user1ChallengeId, 4);
    }
}
