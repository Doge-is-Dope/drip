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
    address private constant CLE = 0x8D0B05b837FB0e28e78b8939dDaD8CE7B91b678D;
    address private constant SHA = 0xE033dfbeE8CB2DaE2F4FB13acb5d493f1fDEA318;

    // Private Keys
    uint256 internal immutable ShanePrivateKey = vm.envUint("PRIVATE_KEY_SHA");

    // Contract Instances
    Challenge challenge;
    ChallengeManager challengeManager;
    DripProfile profile;
    address vault0;
    address vault1;
    // Profiles
    mapping(address => Types.Profile) public profiles;

    function run() public {
        _deployContracts();

        // DEMO ONLY
        _initializeEpochs();
        _createProfiles();

        // Create claimable challenges
        uint256[] memory timestamps1 = new uint256[](5);
        timestamps1[0] = 1;
        timestamps1[1] = 0;
        timestamps1[2] = 0;
        timestamps1[3] = 0;
        timestamps1[4] = 1;
        _createClaimableChallenge(1, 0, timestamps1, 100e18, deployerPrivateKey);
        uint256[] memory timestamps2 = new uint256[](5);
        timestamps2[0] = 1;
        timestamps2[1] = 1;
        timestamps2[2] = 1;
        timestamps2[3] = 1;
        timestamps2[4] = 1;
        _createClaimableChallenge(2, 0, timestamps2, 100e18, ShanePrivateKey);

        // Deployer calculates claimable
        _calculateClaimable(vault0);

        // Create active challenges
        // 0/5
        uint256[] memory ts1 = new uint256[](5);
        ts1[0] = 0;
        ts1[1] = 0;
        ts1[2] = 0;
        ts1[3] = 0;
        ts1[4] = 0;
        _createActiveChallenge(2, 1, "7 Days Quest", "Daily quests for one week", ts1, 101e18, ShanePrivateKey);

        // 1/5
        uint256[] memory ts2 = new uint256[](5);
        ts2[0] = 0;
        ts2[1] = 0;
        ts2[2] = 1;
        ts2[3] = 0;
        ts2[4] = 0;
        _createActiveChallenge(2, 1, "Challenge", "Demo challenge", ts2, 10e18, ShanePrivateKey);

        // 2/5
        uint256[] memory ts3 = new uint256[](5);
        ts3[0] = 0;
        ts3[1] = 0;
        ts3[2] = 1;
        ts3[3] = 0;
        ts3[4] = 1;
        _createActiveChallenge(2, 1, "Happy Challenge", "Practice makes perfect", ts3, 5e18, ShanePrivateKey);

        // 3/5
        uint256[] memory ts4 = new uint256[](5);
        ts4[0] = 0;
        ts4[1] = 1;
        ts4[2] = 1;
        ts4[3] = 1;
        ts4[4] = 0;
        _createActiveChallenge(2, 1, "Better myself", "I luv Challenge", ts4, 12e18, ShanePrivateKey);

        // 5/5
        uint256[] memory ts5 = new uint256[](5);
        ts5[0] = 1;
        ts5[1] = 1;
        ts5[2] = 1;
        ts5[3] = 1;
        ts5[4] = 1;
        _createActiveChallenge(2, 1, "New Begin", "Whole new me", ts4, 100e18, ShanePrivateKey);

        // 4/5
        uint256[] memory ts6 = new uint256[](5);
        ts6[0] = 1;
        ts6[1] = 1;
        ts6[2] = 1;
        ts6[3] = 1;
        ts6[4] = 0;
        _createActiveChallenge(2, 1, "Nailed it", "I'm a pro", ts6, 100e18, ShanePrivateKey);
    }

    function _deployContracts() private {
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

    function _create2Deploy(string memory fileName, bytes memory creationBytecode)
        private
        broadcast(deployerPrivateKey)
        returns (address)
    {
        bytes32 salt = _calculateSalt(fileName);
        return Create2.deploy(0, salt, creationBytecode);
    }

    function _initializeEpochs() private {
        uint256 currentTimestamp = block.timestamp;
        vault0 = _createEpoch(0, currentTimestamp - 5 days, "ETHGlobal Bangkok Demo");
        vault1 = _createEpoch(1, currentTimestamp - 4 days, "TOEFL 7000 words");
        console.log("Epochs initialized");
    }

    /// @notice DEMO only - Helper function to create an epoch
    function _createEpoch(uint256 id, uint256 startTimestamp, string memory description)
        private
        broadcast(deployerPrivateKey)
        returns (address)
    {
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
        return address(vault);
    }

    /// @notice DEMO only - Helper function to create profiles
    function _createProfiles() private {
        uint32[] memory avatar1 = new uint32[](5);
        avatar1[0] = uint32(0);
        avatar1[1] = uint32(0);
        avatar1[2] = uint32(0);
        avatar1[3] = uint32(0);
        avatar1[4] = uint32(0);
        _createProfile("@clement", avatar1, vm.envUint("PRIVATE_KEY"));

        uint32[] memory avatar2 = new uint32[](5);
        avatar2[0] = uint32(1);
        avatar2[1] = uint32(1);
        avatar2[2] = uint32(1);
        avatar2[3] = uint32(1);
        avatar2[4] = uint32(1);
        _createProfile("@shane", avatar2, vm.envUint("PRIVATE_KEY_SHA"));
    }

    function _createProfile(string memory handle, uint32[] memory avatar, uint256 pk) private broadcast(pk) {
        address account = vm.addr(pk);
        uint256 profileId = profile.createProfile(account, handle, avatar);
        Types.Profile memory createdProfile = profile.getProfileById(profileId);
        profiles[account] = createdProfile;
        console.log(handle, "profile with ID:", profileId);

        // Fund profile with mock token
        ERC20Mock(MOCK_TOKEN).setBalance(account, 1_000_000e18);
        ERC20Mock(MOCK_TOKEN).approve(address(challenge), type(uint256).max);
    }

    function _calculateClaimable(address vault) private broadcast(deployerPrivateKey) {
        DripVault(vault).calculateOwnersClaimable();
    }

    function _createClaimableChallenge(
        uint256 profileId,
        uint256 epochId,
        uint256[] memory timestamps,
        uint256 amount,
        uint256 pk
    ) private broadcast(pk) {
        uint256 current = block.timestamp;
        uint256 challengeId =
            profile.createChallengeDemo(profileId, epochId, "Title", "desc", current - 388800, amount, 5);
        profile.setDailyCompletionDemo(challengeId, timestamps);
    }

    function _createActiveChallenge(
        uint256 profileId,
        uint256 epochId,
        string memory title,
        string memory description,
        uint256[] memory timestamps,
        uint256 amount,
        uint256 pk
    ) private broadcast(pk) {
        uint256 current = block.timestamp;
        uint256 challengeId =
            profile.createChallengeDemo(profileId, epochId, title, description, current - 4 days, amount, 5);
        profile.setDailyCompletionDemo(challengeId, timestamps);
    }
}
