// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Oracle {
    AggregatorV3Interface internal immutable priceFeed;

    error GetLastPriceError();

    constructor() {
        // ETH / USD
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function getLatestPrice() public view returns (int256 price) {
        int256 price;
        (, price,,,) = priceFeed.latestRoundData();
        return  price / 1e6;
    }
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
