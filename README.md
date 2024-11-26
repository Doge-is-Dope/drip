<!-- PROJECT LOGO -->
<br />
<p align="center">
    <img src="assets/drip_logo.png" alt="Logo" width="80" height="80">

  <h3 align="center">Drip</h3>

  <p align="center">
    A revolutionary decentralized incentive learning system built on-chain.
    <br />
    <br />
    <a href="https://ethglobal.com/showcase/drip-e73wa">ETHGlobal Showcase</a>
  </p>
</p>

## Overview

Drip is a decentralized protocol that enables users to create and manage challenges, maintain user profiles, and handle tokenized vaults. The system comprises several key components:

- DripProfile: An ERC-721 standard for managing user profiles and associated data.
- Challenge: An ERC-721 token for managing individual challenges.
- ChallengeManager: Coordinates the creation and lifecycle of challenges.
- DripVault: An ERC-4626-compliant vault for token deposits and withdrawals.

## How It Works

1. Initiate a Challenge: Users can start a challenge within a predefined timeframe, committing a deposit amount as collateral.
2. Receive a Progress-Tracking NFT: Participants are issued an NFT upon challenge initiation. This NFT dynamically tracks their progress.
3. Daily Task Completion: Participants complete daily tasks. Their progress is automatically updated and reflected on their NFT.
4. Challenge Outcome:
   - Successful Days: Users can reclaim their deposits for the days they complete tasks successfully.
   - Unsuccessful Days: Deposits for incomplete days are allocated to a reward pool.
   - Additional Rewards: Participants who successfully complete challenges earn additional rewards from the reward pool, funded by incomplete day deposits across all participants.

## Rewards Calculation

**Claimable Deposits**

Represents the amount users can retrieve based on successfully completed days.

![claimable_deposits](assets/reward_claimable_deposits.png)

**Additional Rewards**

Reflects a share of the reward pool distributed to successful participants.
![additional_rewards](assets/reward_additional_rewards.png)

**Total Redemption**

Combines claimable deposits and additional rewards for a comprehensive view of user earnings.

![additional_redemption](assets/reward_total.png)

## Architecture

The protocol consists of four main contracts:

**Challenge.sol**

- Core logic for challenge operations.
- Facilitates challenge creation and manages individual challenge states.
- Retrieves challenges based on specific epochs.

**ChallengeManager.sol**

- Orchestrates the lifecycle of challenges and epochs.
- Establishes new epochs and manages their rewards through the DripVault.

**DripProfile.sol**

- Manages user profile creation and updates.
- Tracks daily task completions for users.

**DripVault.sol**

- Handles tokenized asset management for epoch rewards.
- Facilitates token deposits and withdrawals.

## Deployed Contract Addresses

The protocol utilizes unified CREATE2 addresses for multi-chain deployments:

- Challenge: `0xaDcaAe61b8983940FB2c8098BDe112e507A0e1f0`
- ChallengeManager: `0xB3084eF0Dc7440e32A6cD64e2E5072FBCd9AEEeE`
- DripProfile: `0x0E69Ba1FF53c36D0fbb4fccC0e9B732D58593B2f`

Currently live on the following testnets:

- Base Sepolia
- Mantle Sepolia
- Polygon zkEVM Cardona

## Contributors

<a href="https://github.com/Doge-is-Dope"><img src="https://avatars.githubusercontent.com/u/7845979?v=4" alt="" style="width:5%; border-radius: 50%;" /></a>
<a href="https://github.com/yuhsuan19"><img src="https://avatars.githubusercontent.com/u/22169860?v=4" alt="" style="width:5%; border-radius: 50%;" /></a>
<a href="https://github.com/meatballjim"><img src="https://avatars.githubusercontent.com/u/185509988?v=4" alt="" style="width:5%; border-radius: 50%;" /></a>
<a href="https://github.com/"><img src="https://avatars.githubusercontent.com/u/0?v=4" alt="" style="width:5%; border-radius: 50%;" /></a>
