// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Types} from "../../src/libraries/Types.sol";
import {DripVault} from "../../src/DripVault.sol";
import "./CommonTest.sol";

contract ForkSetUp is CommonTest {
    function setUp() public {
        string memory rpcUrl = vm.envString("RPC_BASE_SEPOLIA");
        vm.createSelectFork(rpcUrl);

        vm.startPrank(DRIP);
        mockToken = new ERC20Mock("Mock", "MCK");
        deal(address(mockToken), USER1, 100 ether);

        challenge = new Challenge();
        challengeManager = new ChallengeManager(address(challenge));
        profile = new DripProfile(address(challenge), address(challengeManager));
        vm.stopPrank();
    }
}
