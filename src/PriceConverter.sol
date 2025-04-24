// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        // address = 0x694AA1769357215DE4FAC081bf1f309aDC325306 = ETH/USD (chainlink price feed)
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (
            ,
            /* uint80 roundId */ int256 answer,
            ,
            ,

        ) = /*uint256 startedAt*/ /*uint256 updatedAt*/ /*uint80 answeredInRound*/ priceFeed
                .latestRoundData();

        //answer is price of ETH in term in USD
        return uint256(answer * 1 ether);
    }

    function getConverionRate(
        uint256 _ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * _ethAmount) / 1 ether; //_ethAmount is the amount of ETH to be converted in USD
        return ethAmountInUsd;
    }
}
