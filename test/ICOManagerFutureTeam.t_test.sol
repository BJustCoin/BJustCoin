// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Bjustcoin} from "../src/Bjustcoin.sol";
import {IVestingToken, Vesting, Schedule} from "../src/IVestingToken.sol";
import {ICOManager, ICOStage, TokenomicType} from "../src/ICOManager.sol";
import {Oracle} from "../src/Oracle.sol";
import "../src/VestingToken.sol";
import "./ICOManagerConst.t_test.sol";

contract ICOManagerFutureTeam_test is Test {
    address internal ALICE = vm.addr(0xA11CE);
    ICOManager public icoManager;
    Oracle private _oracle;
    ICOManagerConst private _icoManagerConst;
    ICOManagerTestScript testScript;
    uint256 gas = 242194;
    //icoManager.MIN_SOLD_VOLUME
    uint256 private constant MIN_SOLD_VOLUME = 10 * 1e8; //10$

    function setUp() public {
        icoManager = new ICOManager();
        _oracle = new Oracle();
        _icoManagerConst = new ICOManagerConst();
        testScript = _icoManagerConst.InitFutureTeamData();
    }

    function getEthCount(uint256 buyUSD) private view returns (uint256) {
        return uint256(buyUSD * 1e18 / icoManager.getRate());
    }

    //Покупка токенов меньше минимальной покупки
    function test_FutureTeamToken_minSoldVolume() public {
        uint256 sendEth = getEthCount(MIN_SOLD_VOLUME - 1);
        icoManager.whitelist(ALICE, TokenomicType.FutureTeam, true);
        startHoax(ALICE, 1000 ether);
        vm.expectRevert(ICOManager.MinSoldError.selector);
        icoManager.buyFutureTeamToken{value: sendEth + gas}();
    }

    //Покупка токенов, для случая когда их недостаточно (цена по 1$ за токен)
    function test_FutureTeamToken_maxusd() public {
        uint256 sendEth = getEthCount(testScript.startParams.maxTokenCount * 1e8);
        icoManager.whitelist(ALICE, TokenomicType.FutureTeam, true);
        console.log("sendEth = ", sendEth);
        startHoax(ALICE, 10000000000 ether);
        vm.expectRevert(ICOManager.InsufficientFunds.selector);
        icoManager.buyFutureTeamToken{value: sendEth + gas}();
    }

    function test_FutureTeamToken_Transfer() public {
        icoManager.transferFutureTeamToken(ALICE, testScript.buyToken.stageTokenBalance * 1e18);
        vm.startPrank(ALICE);

        /**
         * покупка
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.buyToken.stageTokenBalance,
            "(Buy) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.buyToken.availableBalance,
            "(Buy) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, testScript.buyToken.bjcBalance, "(Buy) BJC tokens"
        );
        vm.warp(block.timestamp + testScript.startParams.cliffMonth * 365 days / 12);
        uint256 cliffTimeStamp = block.timestamp;

        /**
         * cliff
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endLess.stageTokenBalance,
            "(Less) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.endLess.availableBalance,
            "(Less) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, testScript.endLess.bjcBalance, "(Less) BJC tokens"
        );
        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * Cliff claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endLessClaim.stageTokenBalance,
            "(Less claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE),
            testScript.endLessClaim.availableBalance,
            "(Less claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.endLessClaim.bjcBalance,
            "(Less claim) BJC tokens"
        );
        vm.warp(cliffTimeStamp + testScript.startParams.vestingPeriod033);
        /**
         * vesting 0.33
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting033.stageTokenBalance,
            "(Vesting 0,33) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vesting033.availableBalance,
            "(Vesting 0,33) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting033.bjcBalance,
            "(Vesting 0,33) BJC tokens"
        );
        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * vesting 0.33 claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim033.stageTokenBalance,
            "(Vesting 0,33 claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vestingClaim033.availableBalance,
            "(Vesting 0,33 claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim033.bjcBalance,
            "(Vesting 0,33 claim) BJC tokens"
        );
        vm.warp(cliffTimeStamp + testScript.startParams.vestingPeriod050);
        /**
         * vesting 0.50
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting050.stageTokenBalance,
            "(Vesting 0,5) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vesting050.availableBalance,
            "(Vesting 0,5) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting050.bjcBalance,
            "(Vesting 0,5) BJC tokens"
        );
        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim050.stageTokenBalance,
            "(Vesting 0,5 claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vestingClaim050.availableBalance,
            "(Vesting 0,5 claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim050.bjcBalance,
            "(Vesting 0,5 claim) BJC tokens"
        );

        vm.warp(cliffTimeStamp + testScript.startParams.vestingPeriod067);
        /**
         * vesting 0.67
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting067.stageTokenBalance,
            "(Vesting 0,67) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vesting067.availableBalance,
            "(Vesting 0,67) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting067.bjcBalance,
            "(Vesting 0,67) BJC tokens"
        );

        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * vesting 0.67 claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim067.stageTokenBalance,
            "(Vesting 0,67 claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vestingClaim067.availableBalance,
            "(Vesting 0,67 claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim067.bjcBalance,
            "(Vesting 0,67 claim) BJC tokens"
        );
        vm.warp(cliffTimeStamp + testScript.startParams.vestingMonth * 365 days / 12);

        /**
         * vesting
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endVesting.stageTokenBalance,
            "(Vesting end) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.endVesting.availableBalance,
            "(Vesting end) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.endVesting.bjcBalance,
            "(Vesting end) BJC tokens"
        );

        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }

        /**
         * vesting claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endVestingClaim.stageTokenBalance,
            "(Vesting end claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.endVestingClaim.availableBalance,
            "(Vesting end claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.endVestingClaim.bjcBalance,
            "(Vesting end claim) BJC tokens"
        );

        vm.stopPrank();
    }

    function test_FutureTeamToken() public {
        uint256 sendEth = getEthCount(testScript.startParams.buyUSD);
        icoManager.whitelist(ALICE, TokenomicType.FutureTeam, true);
        startHoax(ALICE, 10000 ether);
        icoManager.buyFutureTeamToken{value: sendEth + gas}();

        /**
         * покупка
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.buyToken.stageTokenBalance,
            "(Buy) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.buyToken.availableBalance,
            "(Buy) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, testScript.buyToken.bjcBalance, "(Buy) BJC tokens"
        );
        vm.warp(block.timestamp + testScript.startParams.cliffMonth * 365 days / 12);
        uint256 cliffTimeStamp = block.timestamp;

        /**
         * cliff
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endLess.stageTokenBalance,
            "(Less) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.endLess.availableBalance,
            "(Less) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, testScript.endLess.bjcBalance, "(Less) BJC tokens"
        );
        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * Cliff claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endLessClaim.stageTokenBalance,
            "(Less claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE),
            testScript.endLessClaim.availableBalance,
            "(Less claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.endLessClaim.bjcBalance,
            "(Less claim) BJC tokens"
        );
        vm.warp(cliffTimeStamp + testScript.startParams.vestingPeriod033);
        /**
         * vesting 0.33
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting033.stageTokenBalance,
            "(Vesting 0,33) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vesting033.availableBalance,
            "(Vesting 0,33) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting033.bjcBalance,
            "(Vesting 0,33) BJC tokens"
        );
        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * vesting 0.33 claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim033.stageTokenBalance,
            "(Vesting 0,33 claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vestingClaim033.availableBalance,
            "(Vesting 0,33 claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim033.bjcBalance,
            "(Vesting 0,33 claim) BJC tokens"
        );
        vm.warp(cliffTimeStamp + testScript.startParams.vestingPeriod050);
        /**
         * vesting 0.50
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting050.stageTokenBalance,
            "(Vesting 0,5) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vesting050.availableBalance,
            "(Vesting 0,5) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting050.bjcBalance,
            "(Vesting 0,5) BJC tokens"
        );
        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim050.stageTokenBalance,
            "(Vesting 0,5 claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vestingClaim050.availableBalance,
            "(Vesting 0,5 claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim050.bjcBalance,
            "(Vesting 0,5 claim) BJC tokens"
        );

        vm.warp(cliffTimeStamp + testScript.startParams.vestingPeriod067);
        /**
         * vesting 0.67
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting067.stageTokenBalance,
            "(Vesting 0,67) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vesting067.availableBalance,
            "(Vesting 0,67) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vesting067.bjcBalance,
            "(Vesting 0,67) BJC tokens"
        );

        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }
        /**
         * vesting 0.67 claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim067.stageTokenBalance,
            "(Vesting 0,67 claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.vestingClaim067.availableBalance,
            "(Vesting 0,67 claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.vestingClaim067.bjcBalance,
            "(Vesting 0,67 claim) BJC tokens"
        );
        vm.warp(cliffTimeStamp + testScript.startParams.vestingMonth * 365 days / 12);

        /**
         * vesting
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endVesting.stageTokenBalance,
            "(Vesting end) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.endVesting.availableBalance,
            "(Vesting end) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.endVesting.bjcBalance,
            "(Vesting end) BJC tokens"
        );

        if (VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.futureTeamToken()).claim();
        }

        /**
         * vesting claim
         */
        assertEq(
            VestingToken(icoManager.futureTeamToken()).balanceOf(ALICE) / 1e18,
            testScript.endVestingClaim.stageTokenBalance,
            "(Vesting end claim) FutureTeamToken purchased"
        );
        assertEq(
            VestingToken(icoManager.futureTeamToken()).availableBalanceOf(ALICE) / 1e18,
            testScript.endVestingClaim.availableBalance,
            "(Vesting end claim) BJC available"
        );
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            testScript.endVestingClaim.bjcBalance,
            "(Vesting end claim) BJC tokens"
        );

        vm.stopPrank();
    }
}
