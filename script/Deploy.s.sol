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

    // Accounts
    address private constant CLE = 0x8D0B05b837FB0e28e78b8939dDaD8CE7B91b678D;
    address private constant SHA = 0xE033dfbeE8CB2DaE2F4FB13acb5d493f1fDEA318;

    // Private Keys
    uint256 internal immutable ShanePrivateKey = vm.envUint("PRIVATE_KEY_SHA");

    // Contract Instances
    Challenge challenge;
    ChallengeManager challengeManager;
    DripProfile profile;

    // Profiles
    mapping(address => Types.Profile) public profiles;

    function run() public {
        _deployContracts();

        // DEMO ONLY
        _initializeEpochs();
        _createProfiles();
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

    function _initializeEpochs() private broadcast(deployerPrivateKey) {
        uint256 currentTimestamp = block.timestamp;
        _createEpoch(0, currentTimestamp - 5 days, "ETHGlobal Bangkok Demo");
        _createEpoch(1, currentTimestamp - 3 days, "TOEFL 7000 words");
        console.log("Epochs initialized");
    }

    /// @notice DEMO only - Helper function to create an epoch
    function _createEpoch(uint256 id, uint256 startTimestamp, string memory description) private {
        DripVault vault = new DripVault(MOCK_TOKEN, address(challengeManager));
        Types.Epoch memory epoch = Types.Epoch({
            id: id,
            startTimestamp: startTimestamp,
            endTimestamp: startTimestamp + DURATION,
            durationInDays: DURATION.convertSecondsToDays(),
            vault: address(vault),
            asset: MOCK_TOKEN,
            description: description,
            participantCount: 0,
            totalDeposits: 0
        });
        challengeManager.setEpoch(id, epoch);
    }

    /// @notice DEMO only - Helper function to create profiles
    function _createProfiles() private {
        _createProfile("@clement", vm.envUint("PRIVATE_KEY"));
        _createProfile("@shane", vm.envUint("PRIVATE_KEY_SHA"));
    }

    function _createProfile(string memory handle, uint256 pk) private broadcast(pk) {
        address account = vm.addr(pk);
        uint32[] memory avatar = _createAvatar(pk);
        uint256 profileId = profile.createProfile(account, handle, avatar);
        Types.Profile memory createdProfile = profile.getProfileById(profileId);
        profiles[account] = createdProfile;
        console.log(handle, "profile with ID:", profileId);
    }

    function _createAvatar(uint256 seed) private pure returns (uint32[] memory avatar) {
        avatar = new uint32[](5);
        for (uint32 i; i < 5;) {
            avatar[i] = uint32((uint256(keccak256(abi.encodePacked(seed, i)))) + 3);
            unchecked {
                i++;
            }
        }
    }
}
