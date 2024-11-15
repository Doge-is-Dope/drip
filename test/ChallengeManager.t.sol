// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./helpers/SetUp.sol";
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
}
