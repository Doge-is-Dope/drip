// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Create2} from "../lib/openzeppelin-contracts/contracts/utils/Create2.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {ERC20Mock} from "../src/mocks/ERC20Mock.sol";
import {BaseDeploy} from "./BaseDeploy.s.sol";

contract DeployMock is BaseDeploy {
    function run() public {
        // Calculate salt
        bytes32 salt = calculateSalt("Drip.Erc20Mock");
        // Deploy contracts on all supported chains
        address deployed = _deployContract(salt);
        console.log("ERC20Mock deployed to", deployed);
    }

    function _deployContract(bytes32 salt) internal broadcast(deployerPrivateKey) returns (address) {
        return Create2.deploy(0, salt, _getCreationBytecode());
    }

    function _getCreationBytecode() public pure returns (bytes memory) {
        bytes memory bytecode = type(ERC20Mock).creationCode;
        return abi.encodePacked(bytecode, abi.encode("Mock Token", "MTK"));
    }
}
