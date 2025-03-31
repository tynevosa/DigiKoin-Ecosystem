// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceFeed {
    uint256 public constant DEFAULT_ETH_PRICE = 200000000000; // $2,000 with 8 decimals
    uint256 public constant DEFAULT_XAU_PRICE = 300000000000; // $3,000 with 8 decimals

    AggregatorV3Interface internal ethUsdPriceFeed;
    AggregatorV3Interface internal xauUsdPriceFeed;

    /**
     * @dev Constructor to set the price feed addresses
     */
    constructor(address _ethUsdFeed, address _xauUsdFeed) {
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdFeed);
        xauUsdPriceFeed = AggregatorV3Interface(_xauUsdFeed);
    }

    /**
     * @dev Fetches the latest ETH/USD price from Chainlink
     */
    function getEthPrice() public view returns (uint256) {
        // Check if price feed is set
        if (address(ethUsdPriceFeed) == address(0)) {
            return DEFAULT_ETH_PRICE;
        }

        // Attempt to get the price
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();

        // Return the price if valid, otherwise return default
        return price > 0 ? uint256(price) : DEFAULT_ETH_PRICE;
    }

    /**
     * @dev Fetches the latest XAU/USD price from Chainlink
     */
    function getXauPrice() public view returns (uint256) {
        // Check if price feed is set
        if (address(xauUsdPriceFeed) == address(0)) {
            return DEFAULT_XAU_PRICE;
        }

        // Attempt to get the price
        (, int256 price, , , ) = xauUsdPriceFeed.latestRoundData();

        // Return the price if valid, otherwise return default
        return price > 0 ? uint256(price) : DEFAULT_XAU_PRICE;
    }
}
