// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Oracle {
    AggregatorV3Interface internal immutable priceFeed;

    error GetLastPriceError();

    constructor() {
        // ETH / USD 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 (etherium)
        // POL / USD 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0 (polygon)
        priceFeed = AggregatorV3Interface(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);
    }

    /**
     * @notice  usd/eth exchange rate in cents
     * @return  int256  rate in cents
     */
    function getLatestPrice(uint256 defaultRate) public view returns (uint256) {
        int256 price;
        uint256 updatedAt;
        uint256 staleTime = 3600;
        (, price,, updatedAt,) = priceFeed.latestRoundData();
        uint256 result = uint256(price);
        uint256 deltaRate = defaultRate / 5; //20%
        if (result < defaultRate - deltaRate || result > defaultRate + deltaRate) {
            revert GetLastPriceError();
        }
        if (updatedAt < block.timestamp - staleTime) revert GetLastPriceError();
        return result;
    }
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
