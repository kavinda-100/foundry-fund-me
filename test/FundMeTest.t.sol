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

    // modifier to fake the USER the sender
    // this modifier is used to fake the USER the sender of the transaction
    modifier fakeUserWithETH() {
        vm.prank(USER); // fake the USER the sender
        fundMe.fund{value: SEND_VALUE}(); // fund with 5 ETH
        _;
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

    function testFundUpdatesFundedAmount() public payable fakeUserWithETH {
        // check if the funded amount is updated
        uint256 fundedAmount = fundMe.fundedAmountByFunderAddress(USER);
        assertEq(fundedAmount, SEND_VALUE);
    }

    function testFundAddsFunderToArray() public payable fakeUserWithETH {
        // check if the funder is added to the array
        address funder = fundMe.getFunderByIndex(0);
        assertEq(funder, USER);
    }

    function testWithdrawOnlyByOwner() public fakeUserWithETH {
        // expect revert when USER tries to withdraw
        vm.expectRevert();
        fundMe.withdraw(); // only the owner can withdraw
    }

    function testWithdrawWithSingleFunder() public payable fakeUserWithETH {
        // Arrange
        uint256 ownerStartingBalance = fundMe.getOwnerBalance(); // get the owner balance
        uint256 fundMeStartingBalance = address(fundMe).balance; // get the fundMe balance

        //Act
        vm.prank(fundMe.getOwner()); // fake the owner the sender
        fundMe.withdraw(); // withdraw the funds

        // Assert
        uint256 ownerEndingBalance = fundMe.getOwnerBalance(); // get the owner balance after withdraw
        uint256 fundMeEndingBalance = address(fundMe).balance; // get the fundMe balance after withdraw

        assertEq(fundMeEndingBalance, 0); // check if the fundMe balance is 0
        assertEq(
            ownerEndingBalance,
            ownerStartingBalance + fundMeStartingBalance
        ); // check if the owner balance is equal to the starting balance + fundMe balance
    }

    function testWithdrawByMultipleFunders() public payable fakeUserWithETH {
        // Arrange
        uint160 numberOfFunders = 10; // number of funders
        uint160 startingFunderIndex = 1; // starting funder index

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // fund the contract with 5 ETH
            hoax(address(i), SEND_VALUE); // fake the funder the sender
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartingBalance = fundMe.getOwnerBalance(); // get the owner balance
        uint256 fundMeStartingBalance = address(fundMe).balance; // get the fundMe balance

        //Act
        vm.prank(fundMe.getOwner()); // fake the owner the sender
        fundMe.withdraw(); // withdraw the funds

        // Assert
        assert(address(fundMe).balance == 0); // check if the funder is removed from the array
        assertEq(
            fundMe.getOwnerBalance(),
            ownerStartingBalance + fundMeStartingBalance
        ); // check if the owner balance is equal to the starting balance + fundMe balance
    }

    function testTotalAmountOfFund() public payable {
        // 1. create a three funders with 5 ETH each
        // 2. check if the total amount of fund is equal to the sum of the funders
        // 3. check if the total amount of fund is equal to the fundMe balance

        // Arrange
        uint160 numberOfFunders = 3; // number of funders
        uint160 startingFunderIndex = 1; // starting funder index

        for (uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            // fund the contract with 5 ETH
            hoax(address(i), SEND_VALUE); // fake the funder the sender
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 fundMeBalance = address(fundMe).balance; // get the fundMe balance
        uint256 totalAmountOfFund = fundMe.getTotalAmountOfFund(); // get the total amount of fund
        uint256 totalFunders = fundMe.getHowManyFunders(); // get the total number of funders

        // Act

        // Assert
        assertEq(totalAmountOfFund, fundMeBalance); // check if the total amount of fund is equal to the fundMe balance
        assertEq(totalFunders, numberOfFunders); // check if the total number of funders is equal to the number of funders
    }
}
