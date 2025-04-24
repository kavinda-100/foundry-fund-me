// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig; // variable to store the active network configuration

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia
            activeNetworkConfig = getSelpoliaETHConfig();
        }
        {
            // Anvil
            activeNetworkConfig = getAnvilETHConfig();
        }
    }

    function getSelpoliaETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory selpoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return selpoliaConfig;
    }

    function getAnvilETHConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();

        // deploy a mock price feed contract
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            8,
            2000 * 1e8 // 2000 USD
        );
        vm.stopBroadcast();

        // create a new network configuration with the mock price feed address
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilConfig;
    }

    // a getter function for priceFeed
    function getPriceFeed() public view returns (address) {
        return activeNetworkConfig.priceFeed;
    }
}
