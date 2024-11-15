// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC4626, IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract DripVault is ERC4626 {
    constructor(address asset) ERC4626(IERC20(asset)) ERC20("Drip Vault Token", "DRIPVLT") {}
}
