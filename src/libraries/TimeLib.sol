// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library TimeLib {
    using Math for uint256;

    /**
     * @dev Returns the timestamp after a specified number of days from the start time.
     * @param startTime The initial timestamp.
     * @param daysOffset The number of days to add.
     * @return Timestamp of the result.
     */
    function addDaysToTimestamp(uint256 startTime, uint16 daysOffset) internal pure returns (uint256) {
        uint256 dayStartInSeconds = _daysToSeconds(daysOffset);
        return _addSeconds(startTime, dayStartInSeconds);
    }

    function _daysToSeconds(uint16 day) private pure returns (uint256) {
        (bool success, uint256 s) = uint256(day).tryMul(86400);
        require(success, "Multiplication overflow");
        return s;
    }

    function _addSeconds(uint256 timestamp, uint256 secondsToAdd) private pure returns (uint256) {
        (bool success, uint256 newTimestamp) = timestamp.tryAdd(secondsToAdd);
        require(success, "Addition overflow");
        return newTimestamp;
    }
}
