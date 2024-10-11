// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {IVestingToken, Vesting, Schedule} from "../src/IVestingToken.sol";
import "../src/VestingManager.sol";
import "../src/VestingToken.sol";

contract Bjustcoin_test is Test {}
