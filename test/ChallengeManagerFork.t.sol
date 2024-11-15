// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Types} from "../src/libraries/Types.sol";
import "./helpers/ForkSetUp.sol";

/// forge test --match-contract ChallengeManagerForkTest
contract ChallengeManagerForkTest is ForkSetUp {
    /// @notice Demo epoch
    function testSetUpEpoch() public {
        vm.startPrank(DRIP);
        // Epoch 0
        // Status: Ended (Started 6 days ago; Ended 1 day ago)
        _setUpEpoch(0, block.timestamp - 6 days, "Demo epoch 1");
        assertEq(challengeManager.getCurrentEpochId(), 0);
        (Types.Epoch memory epoch1, Types.EpochStatus status1) = challengeManager.getEpochInfo(0);
        assertEq(epoch1.id, 0);
        assertEq(uint256(status1), uint256(Types.EpochStatus.Ended));

        // Epoch 1
        // Status: Active (Starts now; Ends in 5 days)
        _setUpEpoch(1, block.timestamp, "Demo epoch 2");
        assertEq(challengeManager.getCurrentEpochId(), 1); // i.e. total epochs = 2
        (Types.Epoch memory epoch2, Types.EpochStatus status2) = challengeManager.getEpochInfo(1);
        assertEq(epoch2.id, 1);
        assertEq(epoch2.description, "Demo epoch 2");
        assertEq(uint256(status2), uint256(Types.EpochStatus.Active));
        vm.stopPrank();
    }

    function testAddChallengeToEpoch(string calldata handle) public {
        vm.assume(bytes(handle).length > 0);
        // Setup epoch
        vm.startPrank(DRIP);
        _setUpEpoch(0, block.timestamp, "Demo epoch");
        vm.stopPrank();

        vm.startPrank(USER1);
        _approveToken(address(mockToken), address(challenge), type(uint256).max);
        // Create profile
        uint256 profileId = _createProfile(USER1, handle);
        // Create challenges
        profile.createChallenge(profileId, "name", "desc", 100, 2);
        profile.createChallenge(profileId, "name", "desc", 200, 2);

        // Check epoch info
        (Types.Epoch memory epoch, Types.EpochStatus status) = challengeManager.getEpochInfo(0);
        vm.stopPrank();

        assertEq(epoch.id, 0);
        assertEq(uint256(status), uint256(Types.EpochStatus.Active));
        assertEq(epoch.participantCount, 1);
        assertEq(epoch.totalDeposits, 300);
    }
}
