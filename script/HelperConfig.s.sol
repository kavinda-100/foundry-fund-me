// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8; // number of decimals for the price feed
    int256 public constant INITIAL_PRICE = 2000 * 1e8; // initial price for the mock price feed (2000 USD)

    // Define a struct to hold network configuration details
    // This struct contains the address of the price feed contract
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
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getSelpoliaETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory selpoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return selpoliaConfig;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        // Check if the active network configuration is already set
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // return the existing configuration if already set
        }

        vm.startBroadcast();

        // deploy a mock price feed contract
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
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
