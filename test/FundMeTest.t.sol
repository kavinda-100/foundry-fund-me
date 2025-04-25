// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5e18; // 5 ETH
    uint256 constant STARTING_BALANCE = 10 ether; // 10 ETH

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give the USER 10 ETH
    }

    function testOwnerIsMsgSender() external view {
        // check if the owner is the sender
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsCorrect() external view {
        // check if the price feed version is correct
        console.log(fundMe.getPriceFeedVersion());
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund(); // fund with 0 ETH
    }

    function testFundUpdatesFundedAmount() public payable {
        // fake the USER the sender
        vm.prank(USER);
        // fund with 1 ETH
        fundMe.fund{value: SEND_VALUE}();
        // check if the funded amount is updated
        uint256 fundedAmount = fundMe.fundedAmountByFunderAddress(USER);
        assertEq(fundedAmount, SEND_VALUE);
    }

    function testFundAddsFunderToArray() public payable {
        // fake the USER the sender
        vm.prank(USER);
        // fund with 1 ETH
        fundMe.fund{value: SEND_VALUE}();
        // check if the funder is added to the array
        address funder = fundMe.getFunderByIndex(0);
        assertEq(funder, USER);
    }

    function testWithdrawOnlyByOwner() public {
        // fake the USER the sender
        vm.prank(USER);
        // fund with 1 ETH
        fundMe.fund{value: SEND_VALUE}();
        // expect revert when USER tries to withdraw
        vm.expectRevert();
        fundMe.withdraw(); // only the owner can withdraw
    }
}
