// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/ICOManager.sol";

struct ICOManagerTestTimePoint {
    uint256 bjcBalance;
    uint256 stageTokenBalance;
    uint256 availableBalance;
}

struct ICOManagerTestStartParams {
    string nameToken; //наименование токена
    string simvolToken; //символ токена
    uint256 maxTokenCount; //максимальное количество токенов
    uint256 soldTokenCount; //продано токенов
    uint256 price; //цена в центах
    uint8 cliffMonth; //период less, в месяцах
    uint8 vestingMonth; //период vesting, в месяцах
    uint256 buyUSD; //покупка на сумму в в центах
    uint256 vestingPeriod033;
    uint256 vestingPeriod050;
    uint256 vestingPeriod067;
    uint8 unlockTokensPercent;
}

struct ICOManagerTestScript {
    ICOManagerTestStartParams startParams;
    uint256 vestingPeriod033; //количество дней, для проверки данных по вестингу 1/3
    uint256 vestingPeriod050; //количество дней, для проверки данных по вестингу 1/2
    uint256 vestingPeriod066; //количество дней, для проверки данных по вестингу 2/3
    ICOManagerTestTimePoint buyToken;
    ICOManagerTestTimePoint endLess;
    ICOManagerTestTimePoint endLessClaim;
    ICOManagerTestTimePoint vesting033;
    ICOManagerTestTimePoint vestingClaim033;
    ICOManagerTestTimePoint vesting050;
    ICOManagerTestTimePoint vestingClaim050;
    ICOManagerTestTimePoint vesting067;
    ICOManagerTestTimePoint vestingClaim067;
    ICOManagerTestTimePoint endVesting;
    ICOManagerTestTimePoint endVestingClaim;
}

contract ICOManagerConst {
    function InitStrategicData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCStrategic";
        startParams.simvolToken = "BJCSTR";
        startParams.maxTokenCount = 3_000_000;
        startParams.price = 35 * 1e6;
        startParams.cliffMonth = 12;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 0;
        startParams.buyUSD = 105 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 100, bjcBalance: 0});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 0, bjcBalance: 100});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 50, bjcBalance: 100});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 0, bjcBalance: 150});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 50, bjcBalance: 150});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 0, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 100, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 300});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitSeedData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCSeed";
        startParams.simvolToken = "BJCSEED";
        startParams.maxTokenCount = 4_000_000;
        startParams.price = 45 * 1e6;
        startParams.cliffMonth = 12;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 0;
        startParams.buyUSD = 135 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 100, bjcBalance: 0});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 0, bjcBalance: 100});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 50, bjcBalance: 100});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 0, bjcBalance: 150});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 50, bjcBalance: 150});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 0, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 100, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 300});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitPrivateSaleData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCPrivateSale";
        startParams.simvolToken = "BJCPRI";
        startParams.maxTokenCount = 6_000_000;
        startParams.price = 55 * 1e6;
        startParams.cliffMonth = 12;
        startParams.vestingMonth = 28;
        startParams.unlockTokensPercent = 5;
        startParams.buyUSD = 330 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 30, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 570, availableBalance: 0, bjcBalance: 30});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 570, availableBalance: 190, bjcBalance: 30});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 380, availableBalance: 0, bjcBalance: 220});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 380, availableBalance: 95, bjcBalance: 220});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 285, availableBalance: 0, bjcBalance: 315});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 285, availableBalance: 95, bjcBalance: 315});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 190, availableBalance: 0, bjcBalance: 410});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 190, availableBalance: 190, bjcBalance: 410});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitIDOData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCIDO";
        startParams.simvolToken = "BJCIDO";
        startParams.maxTokenCount = 5_000_000;
        startParams.price = 65 * 1e6;
        startParams.cliffMonth = 6;
        startParams.vestingMonth = 30;
        startParams.unlockTokensPercent = 15;
        startParams.buyUSD = 390 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 90, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 510, availableBalance: 0, bjcBalance: 90});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 510, availableBalance: 170, bjcBalance: 90});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 340, availableBalance: 0, bjcBalance: 260});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 340, availableBalance: 85, bjcBalance: 260});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 255, availableBalance: 0, bjcBalance: 345});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 255, availableBalance: 85, bjcBalance: 345});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 170, availableBalance: 0, bjcBalance: 430});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 170, availableBalance: 170, bjcBalance: 430});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitPublicSaleData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCPublicSale";
        startParams.simvolToken = "BJCPUB";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 9;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 5;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 30, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 570, availableBalance: 0, bjcBalance: 30});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 570, availableBalance: 190, bjcBalance: 30});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 380, availableBalance: 0, bjcBalance: 220});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 380, availableBalance: 95, bjcBalance: 220});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 285, availableBalance: 0, bjcBalance: 315});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 285, availableBalance: 95, bjcBalance: 315});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 190, availableBalance: 0, bjcBalance: 410});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 190, availableBalance: 190, bjcBalance: 410});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitAdvisorsData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCSAdvisors";
        startParams.simvolToken = "BJCADV";
        startParams.maxTokenCount = 1_500_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 12;
        startParams.vestingMonth = 36;
        startParams.unlockTokensPercent = 3;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 18, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 582, availableBalance: 0, bjcBalance: 18});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 582, availableBalance: 194, bjcBalance: 18});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 388, availableBalance: 0, bjcBalance: 212});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 388, availableBalance: 97, bjcBalance: 212});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 291, availableBalance: 0, bjcBalance: 309});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 291, availableBalance: 97, bjcBalance: 309});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 194, availableBalance: 0, bjcBalance: 406});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 194, availableBalance: 194, bjcBalance: 406});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitTeamData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCTeam";
        startParams.simvolToken = "BJCTEAM";
        startParams.maxTokenCount = 4_500_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 24;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 5;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 30, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 570, availableBalance: 0, bjcBalance: 30});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 570, availableBalance: 190, bjcBalance: 30});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 380, availableBalance: 0, bjcBalance: 220});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 380, availableBalance: 95, bjcBalance: 220});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 285, availableBalance: 0, bjcBalance: 315});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 285, availableBalance: 95, bjcBalance: 315});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 190, availableBalance: 0, bjcBalance: 410});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 190, availableBalance: 190, bjcBalance: 410});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitFutureTeamData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCFutureTeam";
        startParams.simvolToken = "BJCFUT";
        startParams.maxTokenCount = 5_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 12;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 0;
        startParams.buyUSD = 225 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 100, bjcBalance: 0});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 0, bjcBalance: 100});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 50, bjcBalance: 100});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 0, bjcBalance: 150});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 50, bjcBalance: 150});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 0, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 100, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 300});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitIncentivesData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCIncentives";
        startParams.simvolToken = "BJCINC";
        startParams.maxTokenCount = 11_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 18;
        startParams.unlockTokensPercent = 15;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 90, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 90, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 510, availableBalance: 0, bjcBalance: 90});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 510, availableBalance: 170, bjcBalance: 90});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 340, availableBalance: 0, bjcBalance: 260});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 340, availableBalance: 85, bjcBalance: 260});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 255, availableBalance: 0, bjcBalance: 345});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 255, availableBalance: 85, bjcBalance: 345});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 170, availableBalance: 0, bjcBalance: 430});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 170, availableBalance: 170, bjcBalance: 430});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitLiquidityData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCLiqudity";
        startParams.simvolToken = "BJCLIQ";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 18;
        startParams.unlockTokensPercent = 25;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 150, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 150, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 450, availableBalance: 0, bjcBalance: 150});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 450, availableBalance: 150, bjcBalance: 150});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 300});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 75, bjcBalance: 300});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 225, availableBalance: 0, bjcBalance: 375});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 225, availableBalance: 75, bjcBalance: 375});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 0, bjcBalance: 450});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 150, bjcBalance: 450});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitEcosystemData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCEcosystem";
        startParams.simvolToken = "BJCECO";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 12;
        startParams.unlockTokensPercent = 10;
        startParams.buyUSD = 225 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 30, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 30, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 270, availableBalance: 0, bjcBalance: 30});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 270, availableBalance: 90, bjcBalance: 30});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 180, availableBalance: 0, bjcBalance: 120});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 180, availableBalance: 45, bjcBalance: 120});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 135, availableBalance: 0, bjcBalance: 165});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 135, availableBalance: 45, bjcBalance: 165});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 90, availableBalance: 0, bjcBalance: 210});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 90, availableBalance: 90, bjcBalance: 210});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 300});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;
        return result;
    }

    function InitLoyaltyData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCLoyalty";
        startParams.simvolToken = "BJCLOY";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 48;
        startParams.unlockTokensPercent = 0;
        startParams.buyUSD = 225 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 3, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 0, bjcBalance: 0});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 100, bjcBalance: 0});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 0, bjcBalance: 100});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 200, availableBalance: 50, bjcBalance: 100});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 0, bjcBalance: 150});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 150, availableBalance: 50, bjcBalance: 150});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 0, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 100, availableBalance: 100, bjcBalance: 200});
        ICOManagerTestTimePoint memory endVestingClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 300});

        result.startParams = startParams;
        result.buyToken = buyToken;
        result.endLess = endLess;
        result.endLessClaim = endLessClaim;
        result.vesting033 = vesting033;
        result.vestingClaim033 = vestingClaim033;
        result.vesting050 = vesting050;
        result.vestingClaim050 = vestingClaim050;
        result.vesting067 = vesting067;
        result.vestingClaim067 = vestingClaim067;
        result.endVesting = endVesting;
        result.endVestingClaim = endVestingClaim;

        return result;
    }
}
