// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testOwnerIsMsgSender() external view {
        // check if the owner is the sender
        assertEq(fundMe.getOwner(), address(this));
    }
}
