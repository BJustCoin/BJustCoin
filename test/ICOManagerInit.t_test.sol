// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Bjustcoin} from "../src/Bjustcoin.sol";
import {IVestingToken, Vesting, Schedule} from "../src/IVestingToken.sol";
import {ICOManager, ICOStage} from "../src/ICOManager.sol";
import "../src/VestingToken.sol";

contract ICOManagerInitTest is Test {
    address internal ALICE = vm.addr(0xA11CE);
    ICOManager public icoManager;
    //icoManager.MIN_SOLD_VOLUME
    uint256 private constant MIN_SOLD_VOLUME = 10 * 1e8; //10$

    function setUp() public {
        icoManager = new ICOManager();
    }

    //region Constructor
    function test_constructor() public view {
        Bjustcoin baseToken = Bjustcoin(icoManager.getBaseToken());
        assertEq(baseToken.name(), "Bjustcoin", "baseToken.name");
        assertEq(baseToken.symbol(), "BJC", "baseToken.symbol");

        assertEq(baseToken.totalSupply(), 100_000_000 * (10 ** 18), "baseToken.totalSupply");
        assertEq(baseToken.balanceOf(address(icoManager.owner())), 0, "baseToken.balanceOf(icoManager.owner)");
        assertEq(baseToken.owner(), address(icoManager), "baseToken.owner");
    }
    //endregion

    //region strategicToken
    function test_init_strategic() public view {
        assertEq(icoManager.strategicToken().totalSupply(), 0, "StrategicToken.TotalSypply");
        assertEq(
            icoManager.strategicToken().balanceOf(address(icoManager.owner())),
            0,
            "strategicToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.strategicToken().name(), "BJCStrategic", "strategicToken.name");
        assertEq(icoManager.strategicToken().symbol(), "BJCSTR", "strategicToken.symbol");
        assertEq(icoManager.strategicToken().getMinter(), address(icoManager), "strategicToken.getMinter");

        Vesting memory _vesting = icoManager.strategicToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp + 365 days, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 0, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion
    //region seed

    function test_init_seed() public {
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        assertEq(icoManager.seedToken().totalSupply(), 0, "seedToken.TotalSypply");
        assertEq(
            icoManager.seedToken().balanceOf(address(icoManager.owner())), 0, "seedToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.seedToken().name(), "BJCSeed", "seedToken.name");
        assertEq(icoManager.seedToken().symbol(), "BJCSEED", "seedToken.symbol");
        assertEq(icoManager.seedToken().getMinter(), address(icoManager), "seedToken.getMinter");

        Vesting memory _vesting = icoManager.seedToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp + 365 days / 2, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 15, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion

    //region privateSale
    function test_init_privateSale() public {
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        assertEq(icoManager.privateSaleToken().totalSupply(), 0, "privateSaleToken.TotalSypply");
        assertEq(
            icoManager.privateSaleToken().balanceOf(address(icoManager.owner())),
            0,
            "privateSaleToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.privateSaleToken().name(), "BJCPrivateSale", "privateSaleToken.name");
        assertEq(icoManager.privateSaleToken().symbol(), "BJCPRI", "privateSaleToken.symbol");
        assertEq(icoManager.privateSaleToken().getMinter(), address(icoManager), "privateSaleToken.getMinter");

        Vesting memory _vesting = icoManager.privateSaleToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp + 365 days / 12 * 3, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 30, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 12, "_vesting.schedule.length");
    }
    //endregion

    //region idoSale
    function test_init_ido() public {
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        assertEq(icoManager.idoToken().totalSupply(), 0, "idoToken.TotalSypply");
        assertEq(
            icoManager.idoToken().balanceOf(address(icoManager.owner())), 0, "idoToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.idoToken().name(), "BJCIDO", "idoToken.name");
        assertEq(icoManager.idoToken().symbol(), "BJCIDO", "idoToken.symbol");
        assertEq(icoManager.idoToken().getMinter(), address(icoManager), "idoToken.getMinter");

        Vesting memory _vesting = icoManager.idoToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 0, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 1, "_vesting.schedule.length");
    }
    //endregion

    //region publicSale
    function test_init_publicSale() public {
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        icoManager.nextICOStage();
        assertEq(icoManager.publicSaleToken().totalSupply(), 0, "publicSaleToken.TotalSypply");
        assertEq(
            icoManager.publicSaleToken().balanceOf(address(icoManager.owner())),
            0,
            "publicSaleToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.publicSaleToken().name(), "BJCPublicSale", "publicSaleToken.name");
        assertEq(icoManager.publicSaleToken().symbol(), "BJCPUB", "publicSaleToken.symbol");
        assertEq(icoManager.publicSaleToken().getMinter(), address(icoManager), "publicSaleToken.getMinter");

        Vesting memory _vesting = icoManager.publicSaleToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 0, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 1, "_vesting.schedule.length");
    }
    //endregion

    //region advisors
    function test_init_advisors() public view {
        assertEq(icoManager.advisorsToken().totalSupply(), 0, "advisorsToken.TotalSypply");
        assertEq(
            icoManager.advisorsToken().balanceOf(address(icoManager.owner())),
            0,
            "advisorsToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.advisorsToken().name(), "BJCAdvisors", "advisorsToken.name");
        assertEq(icoManager.advisorsToken().symbol(), "BJCADV", "advisorsToken.symbol");
        assertEq(icoManager.advisorsToken().getMinter(), address(icoManager), "advisorsToken.getMinter");

        Vesting memory _vesting = icoManager.advisorsToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 30, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion

    //region team
    function test_init_team() public view {
        assertEq(icoManager.teamToken().totalSupply(), 0, "teamToken.TotalSypply");
        assertEq(
            icoManager.teamToken().balanceOf(address(icoManager.owner())), 0, "teamToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.teamToken().name(), "BJCTeam", "teamToken.name");
        assertEq(icoManager.teamToken().symbol(), "BJCTEAM", "teamToken.symbol");
        assertEq(icoManager.teamToken().getMinter(), address(icoManager), "teamToken.getMinter");

        Vesting memory _vesting = icoManager.teamToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 30, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion

    //region futureTeam
    function test_init_futureTeam() public view {
        assertEq(icoManager.futureTeamToken().totalSupply(), 0, "futureTeamToken.TotalSypply");
        assertEq(
            icoManager.futureTeamToken().balanceOf(address(icoManager.owner())),
            0,
            "futureTeamToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.futureTeamToken().name(), "BJCFutureTeam", "futureTeamToken.name");
        assertEq(icoManager.futureTeamToken().symbol(), "BJCFUT", "futureTeamToken.symbol");
        assertEq(icoManager.futureTeamToken().getMinter(), address(icoManager), "futureTeamToken.getMinter");

        Vesting memory _vesting = icoManager.futureTeamToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp + 365 days, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 0, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion

    //region Incentives
    function test_init_Incentives() public view {
        assertEq(icoManager.incentivesToken().totalSupply(), 0, "incentivesToken.TotalSypply");
        assertEq(
            icoManager.incentivesToken().balanceOf(address(icoManager.owner())),
            0,
            "incentivesToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.incentivesToken().name(), "BJCIncentives", "incentivesToken.name");
        assertEq(icoManager.incentivesToken().symbol(), "BJCINC", "incentivesToken.symbol");
        assertEq(icoManager.incentivesToken().getMinter(), address(icoManager), "incentivesToken.getMinter");

        Vesting memory _vesting = icoManager.incentivesToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp + 365 days / 12 * 18, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 15, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 15, "_vesting.schedule.length");
    }
    //endregion

    //region Liquidity
    function test_init_Liquidity() public view {
        assertEq(icoManager.liquidityToken().totalSupply(), 0, "liquidityToken.TotalSypply");
        assertEq(
            icoManager.liquidityToken().balanceOf(address(icoManager)), 0, "liquidityToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.liquidityToken().name(), "BJCLiquidity", "liquidityToken.name");
        assertEq(icoManager.liquidityToken().symbol(), "BJCLIQ", "liquidityToken.symbol");
        assertEq(icoManager.liquidityToken().getMinter(), address(icoManager), "liquidityToken.getMinter");

        Vesting memory _vesting = icoManager.liquidityToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 0, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 1, "_vesting.schedule.length");
    }
    //endregion

    //region Ecosystem
    function test_init_Ecosystem() public view {
        assertEq(icoManager.ecosystemToken().totalSupply(), 0, "ecosystemToken.TotalSypply");
        assertEq(
            icoManager.ecosystemToken().balanceOf(address(icoManager.owner())),
            0,
            "ecosystemToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.ecosystemToken().name(), "BJCEcosystem", "ecosystemToken.name");
        assertEq(icoManager.ecosystemToken().symbol(), "BJCECO", "ecosystemToken.symbol");
        assertEq(icoManager.ecosystemToken().getMinter(), address(icoManager), "ecosystemToken.getMinter");

        Vesting memory _vesting = icoManager.ecosystemToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp + 365 days, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 15, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion

    //region Loyalty
    function test_init_Loyalty() public view {
        assertEq(icoManager.loyaltyToken().totalSupply(), 0, "loyaltyToken.TotalSypply");
        assertEq(
            icoManager.loyaltyToken().balanceOf(address(icoManager.owner())),
            0,
            "loyaltyToken.balanceOf(icoManager.owner)"
        );
        assertEq(icoManager.loyaltyToken().name(), "BJCLoyalty", "loyaltyToken.name");
        assertEq(icoManager.loyaltyToken().symbol(), "BJCLOY", "loyaltyToken.symbol");
        assertEq(icoManager.loyaltyToken().getMinter(), address(icoManager), "loyaltyToken.getMinter");

        Vesting memory _vesting = icoManager.loyaltyToken().getVestingSchedule();
        assertEq(_vesting.startTime, block.timestamp, "_vesting.startTime");
        assertEq(_vesting.cliff, block.timestamp, "_vesting.cliff");
        assertEq(_vesting.initialUnlock, 30, "_vesting.initialUnlock");
        assertEq(_vesting.schedule.length, 24, "_vesting.schedule.length");
    }
    //endregion

    function test_birnBJC() public {
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

        Bjustcoin baseToken = Bjustcoin(icoManager.getBaseToken());

        assertEq(baseToken.totalSupply(), 100_000_000 * 1e18 - 35_000_000 * 1e18, "baseToken.totalSupply");
    }
}
