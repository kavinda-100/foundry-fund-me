// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }

    function fundFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded %s with %s ETH", fundMeAddress, SEND_VALUE / 1e18);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }

    function withdrawFundMe(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).withdraw();
        vm.stopBroadcast();
    }
}
