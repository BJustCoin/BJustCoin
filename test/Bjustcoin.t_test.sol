// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {IVestingToken, Vesting, Schedule} from "../src/IVestingToken.sol";
import "../src/VestingManager.sol";
import "../src/VestingToken.sol";
import {Bjustcoin} from "../src/Bjustcoin.sol";

contract Bjustcoin_test is Test {
    Bjustcoin internal bjc;
    address internal ALICE = vm.addr(0xA11CE);
    address internal BOBER = vm.addr(0xB0BE8);
    address internal CHARLY = vm.addr(0xCA417);

    function setUp() public {
        bjc = new Bjustcoin(address(this));
    }

    function test_Bjustcoin_transfer() public {
        bjc.blacklist(BOBER, false);
        bjc.transfer(BOBER, 12 * 1e18);
        assertEq(bjc.balanceOf(BOBER), 12 * 1e18);

        bjc.transfer(CHARLY, 13 * 1e18);
        assertEq(bjc.balanceOf(CHARLY), 13 * 1e18);
    }

    function test_Bjustcoin_transfer_blacklist() public {
        bjc.blacklist(ALICE, true);
        vm.expectRevert(Bjustcoin.Blacklisted.selector);
        bjc.transfer(ALICE, 11 * 1e18);
    }
}
