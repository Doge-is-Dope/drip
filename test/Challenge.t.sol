// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./helpers/SetUp.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IChallenge} from "../src/interfaces/IChallenge.sol";
import {ErrorsLib} from "../src/libraries/ErrorsLib.sol";
import {Types} from "../src/libraries/Types.sol";

contract ChallengeTest is SetUp {
    function setUp() public override {
        super.setUp();

        vm.startPrank(DRIP);
        _setUpEpoch(0, block.timestamp, "Test Epoch");
        vm.stopPrank();
    }

    function testCreateChallenge(uint256 amount, uint16 durationInDays) public {
        amount = bound(amount, 1 ether, 100 ether);
        durationInDays = uint16(bound(durationInDays, 1, 365));

        vm.startPrank(USER1);
        _approveToken(address(mockToken), address(challenge), amount);

        vm.expectEmit(true, true, false, false);
        emit IChallenge.ChallengeCreated(0, USER1);

        uint256 challengeId =
            challenge.createChallenge(Types.CreateChallengeParams(USER1, amount, 0, durationInDays, "title", "desc"));
        vm.stopPrank();

        assertEq(challengeId, 0);
        // Get challenge
        assertEq(challenge.getChallenge(challengeId).owner, USER1);
        assertEq(challenge.getChallenge(challengeId).title, "title");
        assertEq(challenge.getChallenge(challengeId).description, "desc");

        // Get challenges by epoch
        Types.Challenge[] memory challenges = challenge.getChallengesByEpoch(0);
        assertEq(challenges.length, 1);
        // Check challenge details
        assertEq(challenges[0].owner, USER1);
    }

    function testCreateChallenge_InvalidOwner() public {
        vm.prank(USER1);
        vm.expectRevert(bytes(ErrorsLib.NOT_OWNER));
        challenge.createChallenge(Types.CreateChallengeParams(USER2, 1 ether, 0, 7, "test", "test"));
    }

    function testCreateChallenge_InvalidDuration() public {
        vm.prank(USER1);
        vm.expectRevert(bytes(ErrorsLib.INVALID_DURATION));
        challenge.createChallenge(Types.CreateChallengeParams(USER1, 1 ether, 0, 366, "test", "test"));
    }

    function testGetChallenge() public {
        vm.startPrank(USER1);
        _approveToken(address(mockToken), address(challenge), 1 ether);
        challenge.createChallenge(Types.CreateChallengeParams(USER1, 1 ether, 0, 3, "test", "test"));
        vm.stopPrank();

        Types.Challenge memory challenge = challenge.getChallenge(0);
        assertEq(challenge.owner, USER1);
        assertEq(challenge.depositAmount, 1 ether);
        assertEq(challenge.durationInDays, 3);
    }
}
