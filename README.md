# Drip Protocol

A decentralized challenge and profile management system built on Ethereum.

## Overview

Drip Protocol is a smart contract system that enables users to create and manage challenges, maintain profiles, and handle token vaults. The protocol consists of several key components:

- Challenge: Manages individual challenges
- ChallengeManager: Orchestrates challenge creation and management
- DripProfile: Handles user profiles and their associated data
- DripVault: Manages token deposits and withdrawals

## Architecture

The protocol consists of four main contracts:

1. **Challenge.sol**: Core contract for challenge creation and management

   - Creates new challenges
   - Manages challenge states
   - Retrieves challenges for a given epoch

2. **ChallengeManager.sol**: Orchestration layer for challenges management

   - Creates new epochs
   - Manages epoch lifecycle
   - Manages epoch rewards

3. **DripProfile.sol**: User profile management

   - Creates new profiles
   - Manages profile data
   - Submits daily completions

4. **DripVault.sol**: Token management
   - Manages token deposits & withdrawals

## Contract Addresses

Unified CREATE2 addresses:

- Challenge: 0xaDcaAe61b8983940FB2c8098BDe112e507A0e1f0
- ChallengeManager: 0xB3084eF0Dc7440e32A6cD64e2E5072FBCd9AEEeE
- DripProfile: 0x0E69Ba1FF53c36D0fbb4fccC0e9B732D58593B2f

The contracts are deployed on the following networks:

- Base Sepolia
- Mantle Sepolia
- Polygon zkEVM Cardona
