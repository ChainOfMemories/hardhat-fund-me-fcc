// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// libriaries cant have any state variables and cant send any ether. All fcts are internal
library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // ABI and Address needed to interact with contract from outside
        // 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e Goerli Testnet ETH USD
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //   0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        //); // if you match the ABI with an address you get a contract!
        (, int price, , , ) = priceFeed.latestRoundData();
        // ETH in terms of USD above
        // 3000.00000000
        return uint256(price * 1e10); // 1**10
    }

    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        return priceFeed.version();
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
