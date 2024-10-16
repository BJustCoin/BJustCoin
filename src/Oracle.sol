// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Oracle {
    address constant private PRICE_FEED_ADDRESS = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    error GetLastPriceError();

    function getLatestPrice() external view returns (int256) {
        (bool success, bytes memory result) = PRICE_FEED_ADDRESS.staticcall(abi.encodeWithSignature("latestRoundData()"));
        if (!success) revert GetLastPriceError();
        (, int256 price,,,) = abi.decode(result, (uint80, int256, uint256, uint256, uint80));
        return price;
    }
}
