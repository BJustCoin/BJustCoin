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

contract ICOManagerICO_test is Test {
    address internal ALICE = vm.addr(0xA11CE);
    ICOManager public icoManager;
    Oracle private _oracle;
    ICOManagerConst private _icoManagerConst;
    ICOManagerTestScript testScriptStrategic;
    ICOManagerTestScript testScriptSeed;
    ICOManagerTestScript testScriptPrivateSale;
    ICOManagerTestScript testScriptIDO;
    ICOManagerTestScript testScriptPublicSale;
    uint256 gas = 242194;
    uint256 month = 365 days / 12;
    uint256 BJCCurrentBalance = 0;

    receive() external payable {}

    function setUp() public {
        icoManager = new ICOManager();
        _oracle = new Oracle();
        _icoManagerConst = new ICOManagerConst();
        //testScriptStrategic = _icoManagerConst.InitStrategicData();
        testScriptSeed = _icoManagerConst.InitSeedData();
        testScriptPrivateSale = _icoManagerConst.InitPrivateSaleData();
        testScriptIDO = _icoManagerConst.InitIDOData();
        testScriptPublicSale = _icoManagerConst.InitPublicSaleData();

        icoManager.whitelist(ALICE, TokenomicType.Strategic, 10_000_000 * 1e18);
        icoManager.whitelist(ALICE, TokenomicType.Seed, 10_000_000 * 1e18);
        icoManager.whitelist(ALICE, TokenomicType.IDO, 10_000_000 * 1e18);
        icoManager.whitelist(ALICE, TokenomicType.PrivateSale, 10_000_000 * 1e18);
        icoManager.whitelist(ALICE, TokenomicType.PublicSale, 10_000_000 * 1e18);
    }

    function sendEth(uint256 buyUSD) private view returns (uint256) {
        return uint256(buyUSD * 1e18 / uint256(icoManager.getRate()));
    }

    function test_getTokenomicType_ICONotStarted() public {
        vm.expectRevert(ICOManager.ICONotStarted.selector);
        TokenomicType tt1 = icoManager.getTokenomicType();
        assertEq(uint8(tt1), 0, "tt1");
    }

    function test_getTokenomicType_ICOCompleted() public {
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        vm.expectRevert(ICOManager.ICOCompleted.selector);
        TokenomicType tt1 = icoManager.getTokenomicType();
        assertEq(uint8(tt1), 0, "tt1");
    }

    function test_getTokenomicType() public {
        icoManager.nextICOStage();
        assertEq(uint8(icoManager.getTokenomicType()), uint8(TokenomicType.Seed), "tt1");
        icoManager.nextICOStage();
        assertEq(uint8(icoManager.getTokenomicType()), uint8(TokenomicType.PrivateSale), "tt2");
        icoManager.nextICOStage();
        assertEq(uint8(icoManager.getTokenomicType()), uint8(TokenomicType.IDO), "tt3");
        icoManager.nextICOStage();
        assertEq(uint8(icoManager.getTokenomicType()), uint8(TokenomicType.PublicSale), "tt4");
    }

    function test_ICOError_buy_befor_ICOStart() public {
        uint256 eth = sendEth(15) + gas;
        vm.expectRevert(ICOManager.ICONotStarted.selector);
        hoax(ALICE, 5 ether);
        icoManager.buyICOToken{value: eth}();
    }

    function test_ICOToken_transfer() public {
        //seed
        icoManager.nextICOStage();
        icoManager.transferICOToken(ALICE, 200 * 1e18);
        assertEq(VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18, 200, "(Transfer) seedToken");
        //private sale
        icoManager.nextICOStage();
        icoManager.transferICOToken(ALICE, 300 * 1e18);
        assertEq(VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18, 300, "(Transfer) privateToken");
        //ido
        icoManager.nextICOStage();
        icoManager.transferICOToken(ALICE, 400 * 1e18);
        assertEq(VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18, 400, "(Transfer) idoToken");
        //public sale
        icoManager.nextICOStage();
        icoManager.transferICOToken(ALICE, 500 * 1e18);
        assertEq(VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18, 500, "(Transfer) publicToken");
        //end ICO
        icoManager.nextICOStage();
    }

    function test_ICOToken_blacklist() public {
        icoManager.blacklist(ALICE, true);
        icoManager.nextICOStage();
        uint256 eth = sendEth(15 * 1e8) + gas;
        vm.expectRevert(ICOManager.Blacklisted.selector);
        hoax(ALICE, 50000 ether);
        icoManager.buyICOToken{value: eth}();
        icoManager.blacklist(ALICE, false);
        vm.prank(ALICE);
        icoManager.buyICOToken{value: eth}();
    }

    function test_ICOError_buy_after_ICOEnd() public {
        //seed
        icoManager.nextICOStage();
        //private sale
        icoManager.nextICOStage();
        //ido
        icoManager.nextICOStage();
        //public sale
        icoManager.nextICOStage();
        //end ICO
        icoManager.nextICOStage();
        uint256 eth = sendEth(15) + gas;
        vm.expectRevert(ICOManager.ICOCompleted.selector);
        hoax(ALICE, 5 ether);
        icoManager.buyICOToken{value: eth}();
    }

    function test_ICOError_NextICOStage() public {
        //seed
        icoManager.nextICOStage();
        //private sale
        icoManager.nextICOStage();
        //ido
        icoManager.nextICOStage();
        //public sale
        icoManager.nextICOStage();
        //end ICO
        icoManager.nextICOStage();
        //err
        vm.expectRevert(ICOManager.ICOCompleted.selector);
        icoManager.nextICOStage();
    }

    function test_ICOTokenFull() public {
        //to Strategic stage
        icoManager.nextICOStage();
        startHoax(ALICE, 5000 ether);

        test_ICOToken_month1();

        vm.warp(block.timestamp + month);
        vm.stopPrank();
        icoManager.nextICOStage();
        vm.startPrank(ALICE);

        test_ICOToken_month2();

        vm.warp(block.timestamp + month);
        vm.stopPrank();
        icoManager.nextICOStage();
        vm.startPrank(ALICE);

        test_ICOToken_month3();

        vm.warp(block.timestamp + month);
        vm.stopPrank();
        icoManager.nextICOStage();
        vm.startPrank(ALICE);

        test_ICOToken_month4();

        vm.warp(block.timestamp + month);
        test_ICOToken_month5();
        vm.warp(block.timestamp + month);
        test_ICOToken_month6();
        vm.warp(block.timestamp + month);
        test_ICOToken_month7();
        vm.warp(block.timestamp + month);
        test_ICOToken_month8();
        vm.warp(block.timestamp + month);
        test_ICOToken_month9();
        vm.warp(block.timestamp + month);
        test_ICOToken_month10();
        vm.warp(block.timestamp + month);
        test_ICOToken_month11();
        vm.warp(block.timestamp + month);
        test_ICOToken_month12();
        vm.warp(block.timestamp + month);
        test_ICOToken_month13();
        vm.warp(block.timestamp + month);
        test_ICOToken_month14();
        vm.warp(block.timestamp + month);
        test_ICOToken_month15();
        vm.warp(block.timestamp + month);
        test_ICOToken_month16();
        vm.warp(block.timestamp + month);
        test_ICOToken_month17();
        vm.warp(block.timestamp + month);
        test_ICOToken_month18();
        vm.warp(block.timestamp + month);
        test_ICOToken_month19();
        vm.warp(block.timestamp + month);
        test_ICOToken_month20();
        vm.warp(block.timestamp + month);
        test_ICOToken_month21();
        vm.warp(block.timestamp + month);
        test_ICOToken_month22();
        vm.warp(block.timestamp + month);
        test_ICOToken_month23();
        vm.warp(block.timestamp + month);
        test_ICOToken_month24();
        vm.warp(block.timestamp + month);
        test_ICOToken_month25();
        vm.warp(block.timestamp + month);
        test_ICOToken_month26();
        vm.warp(block.timestamp + month);
        test_ICOToken_month27();
        vm.warp(block.timestamp + month);
        test_ICOToken_month28();
        vm.warp(block.timestamp + month);
        test_ICOToken_month29();
        vm.warp(block.timestamp + month);
        test_ICOToken_month30();
        vm.warp(block.timestamp + month);
        test_ICOToken_month31();
        vm.warp(block.timestamp + month);
        test_ICOToken_month32();
        vm.warp(block.timestamp + month);
        test_ICOToken_month33();
        vm.warp(block.timestamp + month);
        test_ICOToken_month34();
        vm.warp(block.timestamp + month);
        test_ICOToken_month35();
        vm.warp(block.timestamp + month);
        test_ICOToken_month36();
        vm.warp(block.timestamp + month);
        test_ICOToken_month37();
        vm.warp(block.timestamp + month);
        test_ICOToken_month38();
        vm.warp(block.timestamp + month);
        test_ICOToken_month39();
        vm.warp(block.timestamp + month);
        test_ICOToken_month40();
        vm.warp(block.timestamp + month);
        test_ICOToken_month41();
        vm.warp(block.timestamp + month);
        test_ICOToken_month42();
        vm.warp(block.timestamp + month);
        vm.stopPrank();
        console.log("balance icoManager", address(icoManager).balance);
        console.log("balance owner", address(this).balance);
        console.log("this", address(this));
        console.log("owner", address(icoManager.owner()));
        icoManager.withdraw();
        console.log("balance icoManager1", address(icoManager).balance);
        console.log("balance owner1", address(this).balance);
    }

    function logBalance(string memory monthNumber) private view {
        if (icoManager.getICOStage() >= ICOStage.Seed) {
            console.log(
                string.concat(monthNumber, " SeedBalance: "),
                VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18
            );
            console.log(
                string.concat(monthNumber, " SeedAvailableBalance: "),
                VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18
            );
        }
        if (icoManager.getICOStage() >= ICOStage.PrivateSale) {
            console.log(
                string.concat(monthNumber, " PrivateSaleBalance: "),
                VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18
            );
            console.log(
                string.concat(monthNumber, " PrivateSaleAvailableBalance: "),
                VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18
            );
        }
        if (icoManager.getICOStage() >= ICOStage.IDO) {
            console.log(
                string.concat(monthNumber, " IDOBalance: "), VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18
            );
            console.log(
                string.concat(monthNumber, " IDOAvailableBalance: "),
                VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18
            );
        }
        if (icoManager.getICOStage() >= ICOStage.PublicSale) {
            console.log(
                string.concat(monthNumber, " PublicSaleBalance: "),
                VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18
            );
            console.log(
                string.concat(monthNumber, " PublicSaleAvailableBalance: "),
                VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18
            );
        }
        console.log(
            string.concat(monthNumber, " BJC Balance: "), ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18
        );
    }

    //region BUY

    function test_ICOToken_month0() private {
        icoManager.buyICOToken{value: sendEth(testScriptStrategic.startParams.buyUSD) + gas}();
        /**
         * покупка Strategic
         */
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.buyToken.stageTokenBalance,
            "(Buy month0) StrategicToken purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.buyToken.availableBalance,
            "(Buy month0) BJC strategic available"
        );
        BJCCurrentBalance += testScriptStrategic.buyToken.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Buy month0) BJC tokens");
        logBalance("month0");
    }

    function test_ICOToken_month1() private {
        icoManager.buyICOToken{value: sendEth(testScriptSeed.startParams.buyUSD) + gas}();
        /**
         * покупка Seed
         */
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.buyToken.stageTokenBalance,
            "(Buy month1) SeedToken purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.buyToken.availableBalance,
            "(Buy month1) BJC seed available"
        );
        BJCCurrentBalance += testScriptSeed.buyToken.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Buy month1) BJC tokens");
        logBalance("month1");
    }

    function test_ICOToken_month2() private {
        icoManager.buyICOToken{value: sendEth(testScriptPrivateSale.startParams.buyUSD) + gas}();
        /**
         * покупка PrivateSale
         */
        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.buyToken.stageTokenBalance,
            "(Buy month2) PrivateSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPrivateSale.buyToken.availableBalance,
            "(Buy month2) BJC PrivateSale available"
        );
        BJCCurrentBalance += testScriptPrivateSale.buyToken.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Buy month2) BJC tokens");
        logBalance("month2");
    }

    function test_ICOToken_month3() private {
        icoManager.buyICOToken{value: sendEth(testScriptIDO.startParams.buyUSD) + gas}();
        /**
         * покупка IDO
         */
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.buyToken.stageTokenBalance,
            "(Buy month3) idoToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.buyToken.availableBalance,
            "(Buy month3) BJC ido available"
        );
        BJCCurrentBalance += testScriptIDO.buyToken.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Buy month3) BJC tokens");
        logBalance("month3");
    }

    function test_ICOToken_month4() private {
        icoManager.buyICOToken{value: sendEth(testScriptPublicSale.startParams.buyUSD) + gas}();
        /**
         * покупка Public sale
         */
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.buyToken.stageTokenBalance,
            "(Buy month4) PublicSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.buyToken.availableBalance,
            "(Buy month4) BJC PublicSale available"
        );
        BJCCurrentBalance += testScriptPublicSale.buyToken.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Buy month4) BJC tokens");
        logBalance("month4");
    }
    //endregion

    function test_ICOToken_month5() private view {
        logBalance("month5");
    }

    function test_ICOToken_month6() private view {
        logBalance("month6");
    }

    function test_ICOToken_month7() private view {
        logBalance("month7");
    }

    function test_ICOToken_month8() private view {
        logBalance("month8");
    }
    //region LESS

    function test_ICOToken_month9() private {
        //less IDO
        /**
         * cliff
         */
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.endLess.stageTokenBalance,
            "(Less) IDO Token purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.endLess.availableBalance,
            "(Less) BJC IDO available"
        );

        //assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less) BJC tokens");
        if (VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.idoToken()).claim();
        }
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.endLessClaim.stageTokenBalance,
            "(Less claim)  IDOToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE),
            testScriptIDO.endLessClaim.availableBalance,
            "(Less claim) BJC IDO available"
        );
        BJCCurrentBalance += testScriptIDO.endLessClaim.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less claim) BJC tokens");

        logBalance("month9");
    }

    function test_ICOToken_month10() private view {
        logBalance("month10");
    }

    function test_ICOToken_month11() private view {
        logBalance("month11");
    }

    function test_ICOToken_month12() private {
        //less Strategic
        /**
         * cliff
         */
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.endLess.stageTokenBalance,
            "(Less) strategic Token purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.endLess.availableBalance,
            "(Less) BJC strategic available"
        );

        /*
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less) BJC strategic tokens"
        );*/
        if (VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.strategicToken()).claim();
        }
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.endLessClaim.stageTokenBalance,
            "(Less claim)  strategicToken purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE),
            testScriptStrategic.endLessClaim.availableBalance,
            "(Less claim) BJC strategic available"
        );
        BJCCurrentBalance += testScriptStrategic.endLessClaim.bjcBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less claim) BJC tokens1"
        );

        logBalance("month12");
    }

    function test_ICOToken_month13() private {
        //less Seed
        //less Public Sale
        /**
         * cliff
         */
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.endLess.stageTokenBalance,
            "(Less) seed Token purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.endLess.availableBalance,
            "(Less) BJC seed available"
        );

        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less) BJC seed tokens");
        if (VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.seedToken()).claim();
        }
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.endLessClaim.stageTokenBalance,
            "(Less claim)  seedToken purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE),
            testScriptSeed.endLessClaim.availableBalance,
            "(Less claim) BJC seed available"
        );

        //assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less claim) BJC tokens");

        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.endLess.stageTokenBalance,
            "(Less) publicSale Token purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.endLess.availableBalance,
            "(Less) BJC publicSale available"
        );

        /*
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less) BJC PublicSale tokens"
        );*/
        if (VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.publicSaleToken()).claim();
        }
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.endLessClaim.stageTokenBalance,
            "(Less claim)  publicSale purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE),
            testScriptPublicSale.endLessClaim.availableBalance,
            "(Less claim) BJC publicSale available"
        );

        BJCCurrentBalance += testScriptPublicSale.endLessClaim.bjcBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less claim) BJC tokens2"
        );

        logBalance("month13");
    }

    function test_ICOToken_month14() private {
        //less Private Sale
        /**
         * cliff
         */
        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.endLess.stageTokenBalance,
            "(Less) strategic Token purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPrivateSale.endLess.availableBalance,
            "(Less) BJC strategic available"
        );

        /*
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Less) BJC private sale tokens"
        );*/
        if (VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.privateSaleToken()).claim();
        }
        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.endLessClaim.stageTokenBalance,
            "(Less claim)  privateSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE),
            testScriptPrivateSale.endLessClaim.availableBalance,
            "(Less claim) BJC strategic available"
        );
        BJCCurrentBalance += testScriptPrivateSale.endLessClaim.bjcBalance;
        assertEq(ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Less claim) BJC tokens");

        logBalance("month14");
    }
    //endregion

    function test_ICOToken_month15() private view {
        logBalance("month15");
    }

    function test_ICOToken_month16() private view {
        logBalance("month16");
    }

    function test_ICOToken_month17() private view {
        logBalance("month17");
    }

    function test_ICOToken_month18() private view {
        logBalance("month18");
    }
    //region vesting033

    function test_ICOToken_month19() private {
        //vesting033 IDO
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.vesting033.stageTokenBalance,
            "(Vesting 0,33) idoToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.vesting033.availableBalance,
            "(Vesting 0,33) BJC IDO available"
        );

        if (VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.idoToken()).claim();
        }
        /**
         * vesting 0.33 claim
         */
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.vestingClaim033.stageTokenBalance,
            "(Vesting 0,33 claim) idoToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.vestingClaim033.availableBalance,
            "(Vesting 0,33 claim) BJC IDO available"
        );
        BJCCurrentBalance += testScriptIDO.vesting033.availableBalance;
        BJCCurrentBalance += testScriptIDO.vestingClaim033.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,33 claim) BJC ido tokens"
        );
        logBalance("month19");
    }

    function test_ICOToken_month20() private {
        //vesting033 Strategic
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.vesting033.stageTokenBalance,
            "(Vesting 0,33) strategicToken purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.vesting033.availableBalance,
            "(Vesting 0,33) BJC strategic available"
        );

        if (VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.strategicToken()).claim();
        }
        /**
         * vesting 0.33 claim
         */
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.vestingClaim033.stageTokenBalance,
            "(Vesting 0,33 claim) strategicToken purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.vestingClaim033.availableBalance,
            "(Vesting 0,33 claim) BJC strategic available"
        );
        BJCCurrentBalance += testScriptStrategic.vesting033.availableBalance;
        BJCCurrentBalance += testScriptStrategic.vestingClaim033.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,33 claim) BJC strategic tokens"
        );
        logBalance("month20");
    }

    function test_ICOToken_month21() private {
        //vesting033 Seed
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.vesting033.stageTokenBalance,
            "(Vesting 0,33) seedToken purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.vesting033.availableBalance,
            "(Vesting 0,33) BJC seed available"
        );

        if (VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.seedToken()).claim();
        }
        /**
         * vesting 0.33 claim
         */
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.vestingClaim033.stageTokenBalance,
            "(Vesting 0,33 claim) seed. purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.vestingClaim033.availableBalance,
            "(Vesting 0,33 claim) BJC seed. available"
        );
        BJCCurrentBalance += testScriptSeed.vesting033.availableBalance;
        BJCCurrentBalance += testScriptSeed.vestingClaim033.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,33 claim) BJC seed. tokens"
        );

        //vesting033 Public Sale
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.vesting033.stageTokenBalance,
            "(Vesting 0,33) publicSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.vesting033.availableBalance,
            "(Vesting 0,33) BJC seed available"
        );

        if (VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.publicSaleToken()).claim();
        }
        /**
         * vesting 0.33 claim
         */
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.vestingClaim033.stageTokenBalance,
            "(Vesting 0,33 claim) PublicSale. purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.vestingClaim033.availableBalance,
            "(Vesting 0,33 claim) BJC PublicSale. available"
        );
        BJCCurrentBalance += testScriptPublicSale.vesting033.availableBalance;
        BJCCurrentBalance += testScriptPublicSale.vestingClaim033.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,33 claim) BJC PublicSale. tokens"
        );
        logBalance("month21");
    }

    function test_ICOToken_month22() private view {
        logBalance("month22");
    }
    //endregion

    function test_ICOToken_month23() private view {
        logBalance("month23");
    }
    //region vesting05

    function test_ICOToken_month24() private {
        //vesting05 Strategic

        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.vesting050.stageTokenBalance,
            "(Vesting 0,50) strategicToken purchased"
        );

        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.vesting050.availableBalance,
            "(Vesting 0,50) BJC strategic available"
        );

        if (VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.strategicToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.vestingClaim050.stageTokenBalance,
            "(Vesting 0,50 claim) strategic. purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.vestingClaim050.availableBalance,
            "(Vesting 0,50 claim) BJC strategic. available"
        );

        BJCCurrentBalance += testScriptStrategic.vesting050.availableBalance;
        BJCCurrentBalance += testScriptStrategic.vestingClaim050.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,50 claim) BJC strategic. tokens"
        );

        //vesting05 IDO
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.vesting050.stageTokenBalance,
            "(Vesting 0,33) idoToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.vesting050.availableBalance,
            "(Vesting 0,33) BJC ido available"
        );

        if (VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.idoToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.vestingClaim050.stageTokenBalance,
            "(Vesting 0,50 claim) ido. purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.vestingClaim050.availableBalance,
            "(Vesting 0,50 claim) BJC ido. available"
        );

        BJCCurrentBalance += testScriptIDO.vesting050.availableBalance;
        BJCCurrentBalance += testScriptIDO.vestingClaim050.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,50 claim) BJC ido. tokens"
        );

        logBalance("month24");
    }

    function test_ICOToken_month25() private {
        //vesting05 Seed

        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.vesting050.stageTokenBalance,
            "(Vesting 0,50) seedToken purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.vesting050.availableBalance,
            "(Vesting 0,50) BJC seed available"
        );

        if (VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.seedToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.vestingClaim050.stageTokenBalance,
            "(Vesting 0,50 claim) seed. purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.vestingClaim050.availableBalance,
            "(Vesting 0,50 claim) BJC seed. available"
        );
        BJCCurrentBalance += testScriptSeed.vesting050.availableBalance;
        BJCCurrentBalance += testScriptSeed.vestingClaim050.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,50 claim) BJC seed. tokens"
        );

        //vesting050 Public Sale
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.vesting050.stageTokenBalance,
            "(Vesting 0,50) publicSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.vesting050.availableBalance,
            "(Vesting 0,50) BJC seed available"
        );

        if (VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.publicSaleToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.vestingClaim050.stageTokenBalance,
            "(Vesting 0,50 claim) seed. purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.vestingClaim050.availableBalance,
            "(Vesting 0,50 claim) BJC seed. available"
        );
        BJCCurrentBalance += testScriptPublicSale.vesting050.availableBalance;
        BJCCurrentBalance += testScriptPublicSale.vestingClaim050.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,50 claim) BJC seed. tokens"
        );
        logBalance("month25");
    }

    function test_ICOToken_month26() private view {
        logBalance("month26");
    }
    //endregion

    function test_ICOToken_month27() private view {
        logBalance("month27");
    }
    //region vesting067

    function test_ICOToken_month28() private {
        //vesting050 privateSale
        //vesting05 Private Sale

        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vesting033.stageTokenBalance,
            "(Vesting 0,50) privateSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vesting033.availableBalance + testScriptPrivateSale.vesting050.availableBalance,
            "(Vesting 0,50) BJC privateSale available"
        );

        if (VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.privateSaleToken()).claim();
        }
        /**
         * vesting 0.50 claim
         */
        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vestingClaim050.stageTokenBalance,
            "(Vesting 0,50 claim) privateSale purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vestingClaim050.availableBalance
                + testScriptPrivateSale.vestingClaim033.availableBalance,
            "(Vesting 0,50 claim) BJC privateSale available"
        );
        BJCCurrentBalance +=
            testScriptPrivateSale.vesting050.availableBalance + testScriptPrivateSale.vesting033.availableBalance;
        BJCCurrentBalance += testScriptPrivateSale.vestingClaim050.availableBalance
            + testScriptPrivateSale.vestingClaim033.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,50 claim) BJC privateSale tokens"
        );
        //vesting050 PrivateSale
        //vesting067 Strategic
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.vesting067.stageTokenBalance,
            "(Vesting 0,67) strategicToken purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.vesting067.availableBalance,
            "(Vesting 0,67) BJC strategic available"
        );

        if (VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.strategicToken()).claim();
        }
        /**
         * vesting 0.67 claim
         */
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.vestingClaim067.stageTokenBalance,
            "(Vesting 0,67 claim) strategicToken purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.vestingClaim067.availableBalance,
            "(Vesting 0,67 claim) BJC strategic available"
        );
        BJCCurrentBalance += testScriptStrategic.vesting067.availableBalance;
        BJCCurrentBalance += testScriptStrategic.vestingClaim067.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,33 claim) BJC strategic tokens"
        );
        logBalance("month28");
    }

    function test_ICOToken_month29() private {
        //vesting067 Seed
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.vesting067.stageTokenBalance,
            "(Vesting 0,67) seedToken purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.vesting067.availableBalance,
            "(Vesting 0,67) BJC seed available"
        );

        if (VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.seedToken()).claim();
        }
        /**
         * vesting 0.67 claim
         */
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.vestingClaim067.stageTokenBalance,
            "(Vesting 0,67 claim) seed. purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.vestingClaim067.availableBalance,
            "(Vesting 0,67 claim) BJC seed. available"
        );
        //vesting067 IDO
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.vesting067.stageTokenBalance,
            "(Vesting 0,67) idoToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.vesting067.availableBalance,
            "(Vesting 0,67) BJC ido available"
        );

        if (VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.idoToken()).claim();
        }
        /**
         * vesting 0.67 claim
         */
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.vestingClaim067.stageTokenBalance,
            "(Vesting 0,67 claim) ido. purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.vestingClaim067.availableBalance,
            "(Vesting 0,67 claim) BJC ido. available"
        );

        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.vesting067.stageTokenBalance,
            "(Vesting 0,67) publicSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.vesting067.availableBalance,
            "(Vesting 0,67) BJC seed available"
        );

        if (VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.publicSaleToken()).claim();
        }
        /**
         * vesting 0.67 claim
         */
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.vestingClaim067.stageTokenBalance,
            "(Vesting 0,67 claim) seed. purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.vestingClaim067.availableBalance,
            "(Vesting 0,67 claim) BJC seed. available"
        );
        //
        BJCCurrentBalance += testScriptSeed.vesting067.availableBalance;
        BJCCurrentBalance += testScriptSeed.vestingClaim067.availableBalance;
        BJCCurrentBalance += testScriptIDO.vesting067.availableBalance;
        BJCCurrentBalance += testScriptIDO.vestingClaim067.availableBalance;
        BJCCurrentBalance += testScriptPublicSale.vesting067.availableBalance;
        BJCCurrentBalance += testScriptPublicSale.vestingClaim067.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,67 claim) BJC month29 (public & ido & seed). tokens"
        );
        logBalance("month29");
    }

    function test_ICOToken_month30() private view {
        logBalance("month30");
    }
    //endregion

    function test_ICOToken_month31() private view {
        logBalance("month31");
    }

    function test_ICOToken_month32() private view {
        logBalance("month32");
    }

    function test_ICOToken_month33() private view {
        logBalance("month33");
    }

    function test_ICOToken_month34() private view {
        logBalance("month34");
    }

    function test_ICOToken_month35() private view {
        logBalance("month35");
    }
    //region vesting

    function test_ICOToken_month36() private {
        //vesting Strategic

        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.endVesting.stageTokenBalance,
            "(Vesting) strategicToken purchased"
        );

        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.endVesting.availableBalance,
            "(Vesting) BJC strategic available"
        );

        if (VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.strategicToken()).claim();
        }
        /**
         * vesting
         */
        assertEq(
            VestingToken(icoManager.strategicToken()).balanceOf(ALICE) / 1e18,
            testScriptStrategic.endVestingClaim.stageTokenBalance,
            "(Vesting claim) strategic. purchased"
        );
        assertEq(
            VestingToken(icoManager.strategicToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptStrategic.endVestingClaim.availableBalance,
            "(Vesting claim) BJC strategic. available"
        );
        BJCCurrentBalance += testScriptStrategic.endVesting.availableBalance;
        BJCCurrentBalance += testScriptStrategic.endVestingClaim.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting) BJC strategic. tokens"
        );
        logBalance("month36");
    }

    function test_ICOToken_month37() private {
        //vesting Seed
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.endVesting.stageTokenBalance,
            "(Vesting) seedToken purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.endVesting.availableBalance,
            "(Vesting) BJC seed available"
        );

        if (VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.seedToken()).claim();
        }
        /**
         * vesting claim
         */
        assertEq(
            VestingToken(icoManager.seedToken()).balanceOf(ALICE) / 1e18,
            testScriptSeed.endVestingClaim.stageTokenBalance,
            "(Vesting claim) seed. purchased"
        );
        assertEq(
            VestingToken(icoManager.seedToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptSeed.endVestingClaim.availableBalance,
            "(Vesting claim) BJC seed. available"
        );
        BJCCurrentBalance += testScriptSeed.endVesting.availableBalance;
        BJCCurrentBalance += testScriptSeed.endVestingClaim.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18, BJCCurrentBalance, "(Vesting) BJC seed. tokens"
        );
        //vesting Public Sale

        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.endVesting.stageTokenBalance,
            "(Vesting) publicSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.endVesting.availableBalance,
            "(Vesting) BJC seed available"
        );

        if (VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.publicSaleToken()).claim();
        }
        /**
         * vesting claim
         */
        assertEq(
            VestingToken(icoManager.publicSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPublicSale.endVestingClaim.stageTokenBalance,
            "(Vesting claim) PublicSale. purchased"
        );
        assertEq(
            VestingToken(icoManager.publicSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPublicSale.endVestingClaim.availableBalance,
            "(Vesting claim) BJC PublicSale. available"
        );
        BJCCurrentBalance += testScriptPublicSale.endVesting.availableBalance;
        BJCCurrentBalance += testScriptPublicSale.endVestingClaim.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting claim) BJC PublicSale. tokens"
        );
        logBalance("month37");
    }

    function test_ICOToken_month38() private view {
        logBalance("month38");
    }

    function test_ICOToken_month39() private {
        //vesting IDO
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.endVesting.stageTokenBalance,
            "(Vesting) idoToken purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.endVesting.availableBalance,
            "(Vesting) BJC ido available"
        );

        if (VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.idoToken()).claim();
        }
        /**
         * vesting claim
         */
        assertEq(
            VestingToken(icoManager.idoToken()).balanceOf(ALICE) / 1e18,
            testScriptIDO.endVestingClaim.stageTokenBalance,
            "(Vesting claim) ido. purchased"
        );
        assertEq(
            VestingToken(icoManager.idoToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptIDO.endVestingClaim.availableBalance,
            "(Vesting claim) BJC ido. available"
        );

        BJCCurrentBalance += testScriptIDO.endVesting.availableBalance;
        BJCCurrentBalance += testScriptIDO.endVestingClaim.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting) BJC month39 (public & ido & seed). tokens"
        );
        logBalance("month39");
    }
    //endregion

    function test_ICOToken_month40() private view {
        logBalance("month40");
    }

    function test_ICOToken_month41() private view {
        logBalance("month41");
    }

    function test_ICOToken_month42() private {
        //vesting private sale

        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vesting067.stageTokenBalance,
            "(Vesting) privateSaleToken purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vesting067.availableBalance + testScriptPrivateSale.endVesting.availableBalance,
            "(Vesting) BJC privateSale available"
        );

        if (VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) > 0) {
            VestingToken(icoManager.privateSaleToken()).claim();
        }
        /**
         * vesting claim
         */
        assertEq(
            VestingToken(icoManager.privateSaleToken()).balanceOf(ALICE) / 1e18,
            testScriptPrivateSale.endVestingClaim.stageTokenBalance,
            "(Vesting claim) privateSale purchased"
        );
        assertEq(
            VestingToken(icoManager.privateSaleToken()).availableBalanceOf(ALICE) / 1e18,
            testScriptPrivateSale.vestingClaim067.availableBalance
                + testScriptPrivateSale.endVestingClaim.availableBalance,
            "(Vesting claim) BJC privateSale available"
        );
        BJCCurrentBalance +=
            testScriptPrivateSale.vesting067.availableBalance + testScriptPrivateSale.endVesting.availableBalance;
        BJCCurrentBalance += testScriptPrivateSale.vestingClaim067.availableBalance
            + testScriptPrivateSale.endVestingClaim.availableBalance;
        assertEq(
            ERC20(icoManager.getBaseToken()).balanceOf(ALICE) / 1e18,
            BJCCurrentBalance,
            "(Vesting 0,50 claim) BJC privateSale tokens"
        );

        logBalance("month42");
    }
}
