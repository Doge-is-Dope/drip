// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./CommonTest.sol";

contract SetUp is CommonTest {
    function setUp() public virtual {
        mockToken = new ERC20Mock("Mock", "MCK");

        // Set up user balances
        deal(address(mockToken), USER1, 100 ether);

        // Deploy contracts
        vm.startPrank(DRIP);
        challenge = new Challenge();
        challengeManager = new ChallengeManager(address(challenge));
        profile = new DripProfile(address(challenge), address(challengeManager));
        vm.stopPrank();
    }
}
