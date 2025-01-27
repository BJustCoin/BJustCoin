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
    string symbolToken; //символ токена
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
        startParams.symbolToken = "BJCSTR";
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
        startParams.symbolToken = "BJCSEED";
        startParams.maxTokenCount = 4_000_000;
        startParams.price = 45 * 1e6;
        startParams.cliffMonth = 6;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 15;
        startParams.buyUSD = 270 * 1e8;
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
            ICOManagerTestTimePoint({stageTokenBalance: 510, availableBalance: 170, bjcBalance: 0});
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

    function InitPrivateSaleData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCPrivateSale";
        startParams.symbolToken = "BJCPRI";
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
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 180, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 420, availableBalance: 0, bjcBalance: 180});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 420, availableBalance: 140, bjcBalance: 180});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 280, availableBalance: 0, bjcBalance: 320});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 280, availableBalance: 70, bjcBalance: 320});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 0, bjcBalance: 390});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 70, bjcBalance: 390});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 0, bjcBalance: 460});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 140, bjcBalance: 460});
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
        startParams.symbolToken = "BJCIDO";
        startParams.maxTokenCount = 5_000_000;
        startParams.price = 65 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 0;
        startParams.unlockTokensPercent = 0;
        startParams.buyUSD = 390 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 600, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 600, bjcBalance: 600});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
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
        startParams.symbolToken = "BJCPUB";
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
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 600, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 600, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
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
        startParams.symbolToken = "BJCADV";
        startParams.maxTokenCount = 1_500_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 30;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 180, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 180, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 420, availableBalance: 0, bjcBalance: 180});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 420, availableBalance: 140, bjcBalance: 180});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 280, availableBalance: 0, bjcBalance: 320});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 280, availableBalance: 70, bjcBalance: 320});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 0, bjcBalance: 390});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 70, bjcBalance: 390});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 0, bjcBalance: 460});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 140, bjcBalance: 460});
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
        startParams.symbolToken = "BJCTEAM";
        startParams.maxTokenCount = 4_500_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 30;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 180, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 180, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 420, availableBalance: 0, bjcBalance: 180});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 420, availableBalance: 140, bjcBalance: 180});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 280, availableBalance: 0, bjcBalance: 320});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 280, availableBalance: 70, bjcBalance: 320});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 0, bjcBalance: 390});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 70, bjcBalance: 390});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 0, bjcBalance: 460});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 140, bjcBalance: 460});
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
        startParams.symbolToken = "BJCFUT";
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
        startParams.symbolToken = "BJCINC";
        startParams.maxTokenCount = 11_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 18;
        startParams.vestingMonth = 15;
        startParams.unlockTokensPercent = 15;
        startParams.buyUSD = 450 * 1e8;
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

    function InitLiquidityData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCLiqudity";
        startParams.symbolToken = "BJCLIQ";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 0;
        startParams.unlockTokensPercent = 0;
        startParams.buyUSD = 450 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 600, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 600, availableBalance: 600, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 0, availableBalance: 0, bjcBalance: 600});
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
        startParams.symbolToken = "BJCECO";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 12;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 15;
        startParams.buyUSD = 450 * 1e8;
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

    function InitLoyaltyData() public pure returns (ICOManagerTestScript memory) {
        ICOManagerTestScript memory result;
        ICOManagerTestStartParams memory startParams;
        startParams.nameToken = "BJCLoyalty";
        startParams.symbolToken = "BJCLOY";
        startParams.maxTokenCount = 15_000_000;
        startParams.price = 75 * 1e6;
        startParams.cliffMonth = 0;
        startParams.vestingMonth = 24;
        startParams.unlockTokensPercent = 30;
        startParams.buyUSD = 225 * 1e8;
        startParams.vestingPeriod033 = (startParams.vestingMonth * 365 days) / (12 * 3);
        startParams.vestingPeriod050 = (startParams.vestingMonth * 365 days) / (12 * 2);
        startParams.vestingPeriod067 = (startParams.vestingMonth * 365 days * 2) / (12 * 3);

        ICOManagerTestTimePoint memory buyToken =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 90, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLess =
            ICOManagerTestTimePoint({stageTokenBalance: 300, availableBalance: 90, bjcBalance: 0});
        ICOManagerTestTimePoint memory endLessClaim =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 0, bjcBalance: 90});
        ICOManagerTestTimePoint memory vesting033 =
            ICOManagerTestTimePoint({stageTokenBalance: 210, availableBalance: 70, bjcBalance: 90});
        ICOManagerTestTimePoint memory vestingClaim033 =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 0, bjcBalance: 160});
        ICOManagerTestTimePoint memory vesting050 =
            ICOManagerTestTimePoint({stageTokenBalance: 140, availableBalance: 35, bjcBalance: 160});
        ICOManagerTestTimePoint memory vestingClaim050 =
            ICOManagerTestTimePoint({stageTokenBalance: 105, availableBalance: 0, bjcBalance: 195});
        ICOManagerTestTimePoint memory vesting067 =
            ICOManagerTestTimePoint({stageTokenBalance: 105, availableBalance: 35, bjcBalance: 195});
        ICOManagerTestTimePoint memory vestingClaim067 =
            ICOManagerTestTimePoint({stageTokenBalance: 70, availableBalance: 0, bjcBalance: 230});
        ICOManagerTestTimePoint memory endVesting =
            ICOManagerTestTimePoint({stageTokenBalance: 70, availableBalance: 70, bjcBalance: 230});
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
