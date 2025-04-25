// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// errors
error Not__Owner();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_owner;
    AggregatorV3Interface internal s_priceFeed;
    uint256 internal constant MINIMUM_USD = 3e18;
    address[] internal s_funders;
    mapping(address funder => uint256 amountFunded)
        internal s_fundedAmountByFunder;

    constructor(address priceFeedAddress) {
        // set the owner when deploying the contract
        i_owner = msg.sender;
        // set the price feed address when deploying the contract
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // utility function for the check then owner
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Only the contract owner can call this function");
        if (msg.sender != i_owner) revert Not__Owner();
        _;
    }

    function fund() public payable {
        // check the value
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to send some Ether. minimum 3 ETH"
        );
        // add to the array
        s_funders.push(msg.sender);
        // add to the mapping
        s_fundedAmountByFunder[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersCount = s_funders.length;
        // rest the mapping
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersCount;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_fundedAmountByFunder[funder] = 0;
        }
        // reset the funders array
        s_funders = new address[](0);
        // transfer the money

        //---- first way -----
        // msg.sender -> address
        // payable(msg.sender) -> payable address
        // payable(msg.sender).transfer(address(this).balance);

        // --- second way ----
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Failed to withdraw the money");

        // --- third way ----
        (bool callSuccess /* bytes memory data */, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Failed to withdraw the money");
    }

    function getTotalAmountOfFund() public view returns (uint256) {
        // add the value of all the mappings in fundedAmountByFunder
        return address(this).balance;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getOwnerBalance() public view returns (uint256) {
        return i_owner.balance;
    }

    function getHowManyFunders() public view returns (uint256) {
        return s_funders.length;
    }

    function getPriceFeedVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function fundedAmountByFunderAddress(
        address funder
    ) public view returns (uint256) {
        return s_fundedAmountByFunder[funder];
    }

    function getFunderByIndex(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    // if user do something accidentally fallback or receive to the fund function by default
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
