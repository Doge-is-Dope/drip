# Drip Protocol

A decentralized challenge and profile management system built on Ethereum.

## Overview

Drip Protocol is a smart contract system that enables users to create and manage challenges, maintain profiles, and handle token vaults. The protocol consists of several key components:

- Challenge: Manages individual challenges
- ChallengeManager: Orchestrates challenge creation and management
- DripProfile: Handles user profiles and their associated data
- DripVault: Manages token deposits and withdrawals

## Contract Addresses

Challenge: 0xaDcaAe61b8983940FB2c8098BDe112e507A0e1f0
ChallengeManager: 0xB3084eF0Dc7440e32A6cD64e2E5072FBCd9AEEeE
DripProfile: 0x0E69Ba1FF53c36D0fbb4fccC0e9B732D58593B2f

### Testnet (Goerli)

- Challenge: [Contract Address]
- ChallengeManager: [Contract Address]
- DripProfile: [Contract Address]
- DripVault: [Contract Address]

## Architecture

The protocol consists of four main contracts:

1. **Challenge.sol**: Core contract for challenge creation and management

   - Handles challenge parameters
   - Manages challenge states
   - Processes challenge completion

2. **ChallengeManager.sol**: Orchestration layer for challenges

   - Creates new challenges
   - Manages challenge lifecycle
   - Handles challenge verification

3. **DripProfile.sol**: User profile management

   - Stores user information
   - Tracks challenge participation
   - Manages user achievements

4. **DripVault.sol**: Token management
   - Handles token deposits
   - Processes withdrawals
   - Manages challenge stakes

## Libraries

### TimeLib

Utility library for time-based calculations and validations used throughout the protocol.

### Types

Contains core data structures and custom types used across the protocol.

## Security

This protocol has been designed with security in mind. However, it has not been audited yet. Use at your own risk.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
