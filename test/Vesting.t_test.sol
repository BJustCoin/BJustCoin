// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {IVestingToken, Vesting, Schedule} from "../src/IVestingToken.sol";
import "../src/VestingManager.sol";
import "../src/VestingToken.sol";

contract VestingTest is Test {
    ERC20Mock internal _baseToken;
    VestingManager internal _vestingManager;
    VestingToken internal _vestingTokenImpl;
    VestingToken internal _vestingToken;
    address internal ALICE = vm.addr(0xA11CE);
    address internal BOBER = vm.addr(0xB0BE8);

    function setUp() public {
        _baseToken = new ERC20Mock();

        _vestingTokenImpl = new VestingToken(5040);
        _vestingManager = new VestingManager(address(_vestingTokenImpl));
    }

    function test_createVestingToken() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 1 days, 5040);
        schedule[0] = scheduleItem;

        string memory name = "VestingToken";
        string memory symbol = "VT";
        address minter = address(this);
        uint256 startTime = block.timestamp;
        uint256 cliff = startTime;
        Vesting memory vestingParams = Vesting(startTime, cliff, 0, schedule);

        address vestingToken = _vestingManager.createVesting(name, symbol, address(_baseToken), minter, vestingParams);

        assertEq(VestingToken(vestingToken).name(), name);
        assertEq(VestingToken(vestingToken).symbol(), symbol);
        assertEq(VestingToken(vestingToken).getVestingSchedule().startTime, startTime);
        assertEq(VestingToken(vestingToken).getVestingSchedule().cliff, cliff);
    }

    function test_mintVestingTokens() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 5040);
        schedule[0] = scheduleItem;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);

        uint256 vestingValue = 1e18;
        _baseToken.mint(address(this), vestingValue);
        _baseToken.approve(vestingToken, vestingValue);

        VestingToken(vestingToken).mint(ALICE, vestingValue);

        assertEq(VestingToken(vestingToken).balanceOf(ALICE), vestingValue);
    }

    function test_claimBaseTokens() public {
        Schedule[] memory schedule = new Schedule[](2);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 2520); //5040);
        Schedule memory scheduleItem1 = Schedule(block.timestamp + 3 days, 2520);
        schedule[0] = scheduleItem;
        schedule[1] = scheduleItem1;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 10, schedule);
        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        uint256 vestingValue = 1e18;
        _baseToken.mint(address(this), vestingValue);
        _baseToken.approve(vestingToken, vestingValue);
        VestingToken(vestingToken).mint(ALICE, vestingValue);

        //start
        uint256 lockedSupply1 = 1e18;
        uint256 unlockedSupply1 = 0;
        assertEq(VestingToken(vestingToken).lockedSupply(), lockedSupply1, "ls1");
        assertEq(VestingToken(vestingToken).unlockedSupply(), unlockedSupply1, "us1");
        console.log("lockedSupply1", VestingToken(vestingToken).lockedSupply());
        console.log("unlockedSupply1", VestingToken(vestingToken).unlockedSupply());
        //cliff
        vm.warp(block.timestamp + 1 days);
        uint256 lockedSupply2 = 9 * 1e17;
        uint256 unlockedSupply2 = 1e17;
        assertEq(VestingToken(vestingToken).lockedSupply(), lockedSupply2, "ls2");
        assertEq(VestingToken(vestingToken).unlockedSupply(), unlockedSupply2, "us2");

        console.log("lockedSupply2", VestingToken(vestingToken).lockedSupply());
        console.log("unlockedSupply2", VestingToken(vestingToken).unlockedSupply());

        //vesting1
        vm.warp(block.timestamp + 1 days);
        uint256 lockedSupply3 = 9 * 1e17 / 2;
        uint256 unlockedSupply3 = 1e17 + 9 * 1e17 / 2;
        console.log("lockedSupply3", VestingToken(vestingToken).lockedSupply());
        console.log("unlockedSupply3", VestingToken(vestingToken).unlockedSupply());
        assertEq(VestingToken(vestingToken).lockedSupply(), lockedSupply3, "ls3");
        assertEq(VestingToken(vestingToken).unlockedSupply(), unlockedSupply3, "us3");

        assertEq(VestingToken(vestingToken).availableBalanceOf(ALICE), unlockedSupply3, "a1");
        assertEq(_baseToken.balanceOf(ALICE), 0, "a2");

        //vesting2
        vm.warp(block.timestamp + 1 days);
        uint256 lockedSupply4 = 0;
        uint256 unlockedSupply4 = 1e18;
        console.log("lockedSupply4", VestingToken(vestingToken).lockedSupply());
        console.log("unlockedSupply4", VestingToken(vestingToken).unlockedSupply());
        assertEq(VestingToken(vestingToken).lockedSupply(), lockedSupply4, "ls4");
        assertEq(VestingToken(vestingToken).unlockedSupply(), unlockedSupply4, "us4");
        //claim
        vm.prank(ALICE);
        VestingToken(vestingToken).claim();
        uint256 lockedSupply5 = 0;
        uint256 unlockedSupply5 = 1e18;
        console.log("lockedSupply5", VestingToken(vestingToken).lockedSupply());
        console.log("unlockedSupply5", VestingToken(vestingToken).unlockedSupply());
        assertEq(_baseToken.balanceOf(ALICE), vestingValue);

        assertEq(VestingToken(vestingToken).lockedSupply(), lockedSupply5, "ls5");
        assertEq(VestingToken(vestingToken).unlockedSupply(), unlockedSupply5, "us5");
        assertEq(VestingToken(vestingToken).balanceOf(ALICE), 0, "a3");
        assertEq(VestingToken(vestingToken).availableBalanceOf(ALICE), 0, "a4");
    }

    function test_NotEnoughTokensToClaim() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 5040);
        schedule[0] = scheduleItem;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);
        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        uint256 vestingValue = 1e18;
        _baseToken.mint(address(this), vestingValue);
        _baseToken.approve(vestingToken, vestingValue);
        VestingToken(vestingToken).mint(ALICE, vestingValue);
        vm.startPrank(ALICE);
        vm.expectRevert(VestingToken.NotEnoughTokensToClaim.selector);
        VestingToken(vestingToken).claim();
        vm.stopPrank();
    }

    function test_transferErrorVestingTokens() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 5040);
        schedule[0] = scheduleItem;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);

        uint256 vestingValue = 1e18;
        _baseToken.mint(address(this), vestingValue);
        _baseToken.approve(vestingToken, vestingValue);

        VestingToken(vestingToken).mint(ALICE, vestingValue);
        vm.startPrank(ALICE);
        vm.expectRevert(VestingToken.TransfersNotAllowed.selector);
        VestingToken(vestingToken).transfer(BOBER, 5 * 1e17);
        vm.stopPrank();
    }

    function test_initialUnlockPercent() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 5040);
        schedule[0] = scheduleItem;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 101, schedule);
        vm.expectRevert(VestingToken.PercentError.selector);
        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        assertEq(vestingToken, address(0));
    }

    function test_onlyVestingManager() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 5040);
        schedule[0] = scheduleItem;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);

        vm.startPrank(ALICE);
        vm.expectRevert(VestingToken.OnlyVestingManager.selector);
        VestingToken(vestingToken).setVestingSchedule(
            vestingParams.startTime, vestingParams.cliff, 10, vestingParams.schedule
        );
        vm.stopPrank();
    }

    function test_minterOnlymintVestingTokens() public {
        Schedule[] memory schedule = new Schedule[](1);
        Schedule memory scheduleItem = Schedule(block.timestamp + 2 days, 5040);
        schedule[0] = scheduleItem;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);

        uint256 vestingValue = 1e18;
        _baseToken.mint(address(this), vestingValue);
        _baseToken.approve(vestingToken, vestingValue);
        vm.startPrank(ALICE);
        vm.expectRevert(VestingToken.OnlyMinter.selector);
        VestingToken(vestingToken).mint(ALICE, vestingValue);
        vm.stopPrank();
    }

    function testFail_IncorrectSchedulePortions() public {
        Schedule[] memory schedule = new Schedule[](2);
        Schedule memory scheduleItem1 = Schedule(block.timestamp + 2 days, 2000);
        Schedule memory scheduleItem2 = Schedule(block.timestamp + 3 days, 2000);
        schedule[0] = scheduleItem1;
        schedule[1] = scheduleItem2;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);
        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);

        console.log("totalSupply", VestingToken(vestingToken).totalSupply());
    }

    function testFail_IncorrectScheduleTime() public {
        Schedule[] memory schedule = new Schedule[](2);
        Schedule memory scheduleItem1 = Schedule(block.timestamp + 2 days, 5040 / 2);
        Schedule memory scheduleItem2 = Schedule(block.timestamp, 5040 / 2);
        schedule[0] = scheduleItem1;
        schedule[1] = scheduleItem2;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);
        //vm.expectRevert(VestingToken.IncorrectScheduleTime.selector);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        console.log("totalSupply", VestingToken(vestingToken).totalSupply());
    }

    function testFail_StartTimeAlreadyElapsed() public {
        uint256 startTime = block.timestamp;
        vm.warp(block.timestamp + 1 days);
        Schedule[] memory schedule = new Schedule[](2);
        Schedule memory scheduleItem1 = Schedule(block.timestamp + 2 days, 5040 / 2);
        Schedule memory scheduleItem2 = Schedule(block.timestamp + 3 days, 5040 / 2);
        schedule[0] = scheduleItem1;
        schedule[1] = scheduleItem2;

        Vesting memory vestingParams = Vesting(startTime, startTime + 1 days, 0, schedule);
        //vm.expectRevert(VestingToken.IncorrectScheduleTime.selector);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        console.log("totalSupply", VestingToken(vestingToken).totalSupply());
    }

    function testFail_CliffBeforeStartTime() public {
        Schedule[] memory schedule = new Schedule[](2);
        Schedule memory scheduleItem1 = Schedule(block.timestamp + 2 days, 5040 / 2);
        Schedule memory scheduleItem2 = Schedule(block.timestamp + 3 days, 5040 / 2);
        schedule[0] = scheduleItem1;
        schedule[1] = scheduleItem2;

        Vesting memory vestingParams = Vesting(block.timestamp + 2 days, block.timestamp + 1 days, 0, schedule);
        //vm.expectRevert(VestingToken.IncorrectScheduleTime.selector);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        console.log("totalSupply", VestingToken(vestingToken).totalSupply());
    }

    function test_MintingAfterCliffIsForbidden() public {
        Schedule[] memory schedule = new Schedule[](2);
        Schedule memory scheduleItem1 = Schedule(block.timestamp + 2 days, 5040 / 2);
        Schedule memory scheduleItem2 = Schedule(block.timestamp + 3 days, 5040 / 2);
        schedule[0] = scheduleItem1;
        schedule[1] = scheduleItem2;

        Vesting memory vestingParams = Vesting(block.timestamp, block.timestamp + 1 days, 0, schedule);

        address vestingToken =
            _vestingManager.createVesting("VestingToken", "VT", address(_baseToken), address(this), vestingParams);
        console.log("totalSupply", VestingToken(vestingToken).totalSupply());
        uint256 vestingValue = 1e18;
        vm.warp(block.timestamp + 5 days);

        _baseToken.mint(address(this), vestingValue);
        _baseToken.approve(vestingToken, vestingValue);
        vm.expectRevert(VestingToken.MintingAfterCliffIsForbidden.selector);
        VestingToken(vestingToken).mint(ALICE, vestingValue);
    }
}
