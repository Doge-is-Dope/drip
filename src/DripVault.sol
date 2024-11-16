// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Types} from "./libraries/Types.sol";
import {console} from "forge-std/console.sol";

contract DripVault is ERC4626 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256;

    EnumerableSet.AddressSet private owners;
    // Owner => Original deposits
    mapping(address => uint256) public ownerDeposits;
    // Owner => Total challenge days
    mapping(address => uint256) public ownerChallengeDays;
    // Owner => Daily completions count
    mapping(address => uint256) public ownerDailyCompletions;
    // Owner => Claimable amount
    mapping(address => uint256) public ownerClaimables;

    address public challengeManager;
    uint256 public totalDailyCompletionCount;

    modifier onlyChallengeManager() {
        require(msg.sender == challengeManager, "Only challenge managers can call this function");
        _;
    }

    constructor(address asset, address _challengeManager)
        ERC4626(IERC20(asset))
        ERC20("Drip Vault Token", "DRIP-VLT")
    {
        challengeManager = _challengeManager;
    }

    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        ownerDeposits[receiver] += assets;
        return super.deposit(assets, receiver);
    }

    function setOwnerChallengeDays(address owner, uint256 challengeDays) external {
        ownerChallengeDays[owner] = challengeDays;
    }

    function previewClaim(address owner) external view returns (uint256) {
        return ownerClaimables[owner];
    }

    function claim(address owner) external onlyChallengeManager {
        uint256 claimable = ownerClaimables[owner];
        require(claimable > 0, "No claimable amount");
        uint256 userShares = IERC20(this).balanceOf(owner);
        require(userShares > 0, "No shares to burn");
        _burn(owner, userShares);
        ownerClaimables[owner] = 0;
        ERC20(asset()).transfer(owner, claimable);
    }

    function submitDailyCompletion(address owner, uint256[] calldata dailyCompletion) external {
        uint256 completedDays = 0;
        for (uint256 i = 0; i < dailyCompletion.length;) {
            if (dailyCompletion[i] > 0) {
                completedDays++;
            }
            unchecked {
                i++;
            }
        }
        owners.add(owner);
        ownerDailyCompletions[owner] = completedDays;
        totalDailyCompletionCount++;
    }

    function calculateOwnersClaimable() public {
        uint256 ownerCount = owners.length(); // Cache length to avoid repeated calls
        require(ownerCount > 0, "No owners to calculate");

        uint256 totalClaimableDeposits = 0;
        uint256 totalDeposits = totalAssets();
        require(totalDeposits > 0, "Total deposits must be greater than zero");

        // Cache remaining rewards calculation to reduce computations
        uint256[] memory claimableDeposits = new uint256[](ownerCount);

        // First pass: Calculate claimable deposits
        for (uint256 i; i < ownerCount;) {
            address owner = owners.at(i);

            uint256 userDeposits = ownerDeposits[owner];
            uint256 completedDays = ownerDailyCompletions[owner];
            uint256 totalDays = ownerChallengeDays[owner];

            uint256 claimable = 0;
            if (totalDays > 0 && completedDays > 0) {
                claimable = Math.mulDiv(userDeposits, completedDays, totalDays);
            }

            claimableDeposits[i] = claimable; // Cache claimable deposit for later
            ownerClaimables[owner] = claimable; // Update state
            totalClaimableDeposits += claimable;
            unchecked {
                i++;
            }
        }

        // Calculate remaining rewards once
        if (totalClaimableDeposits < totalDeposits) {
            uint256 remainingRewards = totalDeposits - totalClaimableDeposits;

            // Second pass: Add additional rewards
            for (uint256 i; i < ownerCount;) {
                address owner = owners.at(i);
                uint256 userDeposits = ownerDeposits[owner];

                if (userDeposits > 0) {
                    uint256 additionalRewards = Math.mulDiv(userDeposits, remainingRewards, totalDeposits);
                    ownerClaimables[owner] += additionalRewards; // Add to claimable
                }
                unchecked {
                    i++;
                }
            }
        }
    }
}
