// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/forge-std/src/Script.sol";

contract BaseDeploy is Script {
    uint256 internal immutable deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    modifier broadcast(uint256 privateKey) {
        require(privateKey != 0, "Private key is required");
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }

    function _calculateSalt(string memory input) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(input)) & ~bytes32(uint256(0xffff) - 5);
    }
}
