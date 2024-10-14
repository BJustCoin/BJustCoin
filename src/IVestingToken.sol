// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20.0;

struct Schedule {
    uint256 endTime;
    uint256 portion;
}

struct Vesting {
    uint256 startTime;
    uint256 cliff;
    uint8 initialUnlock;
    Schedule[] schedule;
}

/**
 * @author  .
 * @title   .
 * @dev     .
 * @notice  .
 */
interface IVestingToken {
    function initialize(string calldata name, string calldata symbol, address minter, address token) external;

    /**
     * @notice  .
     * @dev     .
     * @param   startTime  .
     * @param   cliff  .
     * @param   initialUnlock  .
     * @param   schedule  .
     */
    function setVestingSchedule(uint256 startTime, uint256 cliff, uint8 initialUnlock, Schedule[] calldata schedule)
        external;

    /**
     * @notice  .
     * @dev     .
     * @param   to  .
     * @param   amount  .
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice  .
     * @dev     .
     * @return  Vesting  .
     */
    function getVestingSchedule() external view returns (Vesting memory);
}
