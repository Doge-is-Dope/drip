# Drip

A revolutionary decentralized incentive learning system built on-chain.

## Overview

Drip enables users to create and manage challenges, maintain user profiles, and handle tokenized vaults. The system is composed of several key components:

- DripProfile: An ERC-721 that governs user profiles and associated data.
- Challenge: An ERC-721 to manage individual challenges.
- ChallengeManager: Coordinates the creation and lifecycle management of challenges.
- DripVault: An ERC-4626-compliant vault that handles token deposits and withdrawals.

## How It Works

1. Initiate a Challenge:
   - Learners can start a challenge within a predefined timeframe, choosing an amount to deposit as a commitment.
2. Receive a Progress-Tracking NFT:
   - Upon creation, the learner is issued an NFT that records their challenge progress.
3. Daily Task Completion:
   - Learners complete assigned tasks daily. Task progress is automatically updated and reflected in the NFT.
4. Challenge Outcome:
   - For Successful Days: Learners retrieve their deposited amount corresponding to the days completed successfully.
   - For Unsuccessful Days: The deposits for incomplete days are allocated to the reward pool to incentivize successful participants.
   - Additional Rewards: Successful learners earn an additional reward from the share of the reward pool accumulated from the deposits of all incomplete days across participants.

## Architecture

The protocol consists of four main contracts:

**Challenge.sol**: Foundational contract for challenge operations.

- Facilitates challenge creation.
- Manages the state of individual challenges.
- Retrieves challenges for a specific epoch.

**ChallengeManager.sol**: Orchestration layer for challenge lifecycles.

- Establishes new epochs.
- Manages the lifecycle of epochs.
- Oversees epoch rewards using the DripVault.

**DripProfile.sol**: User profiles management and engagement.

- Enables profile creation.
- Maintains and updates profile data.
- Tracks and records daily completions.

**DripVault.sol**: Tokenized asset management of epoch rewards.

- Facilitates deposits and withdrawals of tokens.

## Deployed Contract Addresses

Unified CREATE2 addresses for multi-chain deployment:

- Challenge: `0xaDcaAe61b8983940FB2c8098BDe112e507A0e1f0`
- ChallengeManager: `0xB3084eF0Dc7440e32A6cD64e2E5072FBCd9AEEeE`
- DripProfile: `0x0E69Ba1FF53c36D0fbb4fccC0e9B732D58593B2f`

The contracts are live on the following testnets:

- Base Sepolia
- Mantle Sepolia
- Polygon zkEVM Cardona
