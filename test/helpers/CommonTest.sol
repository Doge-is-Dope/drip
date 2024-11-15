// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../../src/mocks/ERC20Mock.sol";
import {Challenge} from "../../src/Challenge.sol";
import {DripProfile} from "../../src/DripProfile.sol";
import {ChallengeManager} from "../../src/ChallengeManager.sol";
import {DripVault} from "../../src/DripVault.sol";
import {Types} from "../../src/libraries/Types.sol";

uint256 constant MIN_AMOUNT = 100;
uint256 constant MAX_AMOUNT = 2 ** 64;
uint256 constant DURATION = 5 days;

contract CommonTest is Test {
    DripProfile internal profile;
    Challenge internal challenge;
    ChallengeManager internal challengeManager;
    ERC20Mock internal mockToken;

    address internal DRIP = makeAddr("drip");
    address internal USER1 = makeAddr("user1");
    address internal USER2 = makeAddr("user2");

    /// DripProfile Helper ///

    /// @notice Helper: Create a avatar at specific length
    /// @param length The length of the avatar
    /// @return avatar The avatar
    function _createAvatar(uint8 length) internal pure returns (uint32[] memory) {
        uint32[] memory avatar = new uint32[](length);
        for (uint8 i = 0; i < length; i++) {
            avatar[i] = 0;
        }
        return avatar;
    }

    /// @notice Helper: Create a profile for a specific owner
    /// @param owner The owner of the profile
    /// @return profileId The ID of the created profile
    function _createProfile(address owner, string calldata handle) internal returns (uint256) {
        uint32[] memory avatar = _createAvatar(5);
        return profile.createProfile(owner, handle, avatar);
    }

    function _setUpEpoch(uint256 id, uint256 startTimestamp, string memory description) internal {
        DripVault vault = new DripVault(address(mockToken));
        Types.Epoch memory epoch = Types.Epoch({
            id: id,
            startTimestamp: startTimestamp,
            endTimestamp: startTimestamp + DURATION,
            durationInDays: _getDurationInDays(DURATION),
            vault: address(vault),
            asset: address(mockToken),
            description: description,
            participantCount: 0,
            totalDeposits: 0
        });
        challengeManager.setEpoch(id, epoch);
    }

    function _getDurationInDays(uint256 duration) private pure returns (uint16) {
        return uint16(duration / 1 days);
    }

    function _approveToken(address token, address spender, uint256 amount) internal {
        IERC20(token).approve(spender, amount);
    }
}
