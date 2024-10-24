// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVestingToken, Vesting} from "./IVestingToken.sol";

/**
 * @title Контракт-фабрика для создания share-токенов
 * @notice Основная задача смарт-контракта создавать экземпляры share-токенов
 * и устанавливать на них расписание вестинга
 * @dev
 */
contract VestingManager is Ownable {
    address private immutable _vestingImplementation;

    error ImplementationError();

    constructor(address implementation) Ownable(msg.sender) {
        if (implementation == address(0)) revert ImplementationError();
        _vestingImplementation = implementation;
    }

    /**
     * @notice Основная функция для создания экземпляра share-токена
     * Т.к. это создание ERC20 - задаем name и symbol
     * Указываем адрес токена который будет блокироваться под вестинг
     * Указываем адрес который сможет минтить share-токены (к примеру контракт продаж)
     * Передаем расписание
     */
    function createVesting(
        string calldata name,
        string calldata symbol,
        address baseToken,
        address minter,
        Vesting calldata vesting
    ) external onlyOwner returns (address vestingToken) {
        vestingToken = _createVestingToken(name, symbol, minter, baseToken);

        IVestingToken(vestingToken).setVestingSchedule(
            vesting.startTime, vesting.cliff, vesting.initialUnlock, vesting.schedule
        );
    }

    function _createVestingToken(string calldata name, string calldata symbol, address minter, address baseToken)
        private
        returns (address vestingToken)
    {
        vestingToken = Clones.clone(_vestingImplementation);
        IVestingToken(vestingToken).initialize(name, symbol, minter, baseToken);
    }
}
