// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import { Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IVestingToken, Vesting} from "./IVestingToken.sol";

/**
 * @title Contract factory for the creation of vestingTokens
 * @notice The main task of a smart contract is to create instances of vestingTokens and set a vesting schedule on them
 * @dev
 */
contract VestingManager is Ownable2Step { 
    address private immutable _vestingImplementation;

    event CreateVestingToken(address indexed addressToken, string name, string symbol);

    error ImplementationError();

    constructor(address implementation) Ownable(msg.sender) {
        if (implementation == address(0)) revert ImplementationError();
        _vestingImplementation = implementation;
    }

    /**
     * @notice The main function for creating an instance of a vestingTokens
     * setting the name and symbol
     * We specify the address of the token that will be blocked for vesting
     * We specify the address that will be able to use share tokens (for example, a sales contract)
     * Passing the schedule
     */
    function createVesting(
        string calldata name,
        string calldata symbol,
        address baseToken,
        address minter,
        Vesting calldata vesting
    ) external onlyOwner returns (address vestingToken) {
        vestingToken = _createVestingToken(name, symbol, minter, baseToken);
        emit CreateVestingToken(vestingToken, name, symbol);
        IVestingToken(vestingToken).setVestingSchedule(
            vesting.startTime, vesting.cliff, vesting.initialUnlock, vesting.schedule
        );
    }

    /**
     * @dev     create new token
     * @param   name  name token
     * @param   symbol symvol token
     * @param   minter  the address that owns the right to mint new token
     * @param   baseToken  base token
     * @return  vestingToken  address new token
     */
    function _createVestingToken(string calldata name, string calldata symbol, address minter, address baseToken)
        private
        returns (address vestingToken)
    {
        vestingToken = Clones.clone(_vestingImplementation);
        IVestingToken(vestingToken).initialize(name, symbol, minter, baseToken);
    }
}
