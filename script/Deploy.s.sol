// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Create2} from "../lib/openzeppelin-contracts/contracts/utils/Create2.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {ERC20Mock} from "../src/mocks/ERC20Mock.sol";
import {Challenge} from "../src/Challenge.sol";
import {DripProfile} from "../src/DripProfile.sol";
import {ChallengeManager} from "../src/ChallengeManager.sol";
import {DripVault} from "../src/DripVault.sol";
import {Types} from "../src/libraries/Types.sol";
import {TimeLib} from "../src/libraries/TimeLib.sol";
import {BaseDeploy} from "./BaseDeploy.s.sol";

contract Deploy is BaseDeploy {
    using TimeLib for uint256;

    // Constants
    uint256 private constant DURATION = 5 days;
    address private constant MOCK_TOKEN = 0x235c36243BD73d65B530a469658FeF591daA2f45; // Vault: underlying token

    // Contract Instances
    Challenge challenge;
    ChallengeManager challengeManager;
    DripProfile profile;

    // Profiles
    mapping(address => Types.Profile) public profiles;

    function run() public {
        _deployContracts();
    }

    function _deployContracts() private broadcast(deployerPrivateKey) {
        // Deploy Challenge
        bytes memory challengeBytecode = abi.encodePacked(type(Challenge).creationCode);
        challenge = Challenge(_create2Deploy("Drip.Challenge.ff", challengeBytecode));
        console.log("Challenge deployed to", address(challenge));

        // Deploy ChallengeManager
        bytes memory managerBytecode =
            abi.encodePacked(type(ChallengeManager).creationCode, abi.encode(address(challenge)));
        challengeManager = ChallengeManager(_create2Deploy("Drip.ChallengeManager.ff", managerBytecode));
        console.log("ChallengeManager deployed to", address(challengeManager));

        // Deploy DripProfile
        bytes memory profileBytecode =
            abi.encodePacked(type(DripProfile).creationCode, abi.encode(address(challenge), address(challengeManager)));
        profile = DripProfile(_create2Deploy("Drip.Profile.ff", profileBytecode));
        console.log("DripProfile deployed to", address(profile));
    }

    function _create2Deploy(string memory fileName, bytes memory creationBytecode) private returns (address) {
        bytes32 salt = _calculateSalt(fileName);
        return Create2.deploy(0, salt, creationBytecode);
    }
}
