// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {PriceConverter} from "./PriceConverter.sol";

// errors
error Not_Owner();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_owner;
    uint256 internal constant MINIMUM_USD = 1 ether;
    address[] internal funders;
    mapping(address funder => uint256 amountFunded) public fundedAmountByFunder;

    constructor() {
        // set the owner when deploying the contract
        i_owner = msg.sender;
    }

    // utility function for the check then owner
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Only the contract owner can call this function");
        if (msg.sender != i_owner) revert Not_Owner();
        _;
    }

    function fund() public payable {
        // check the value
        require(
            msg.value.getConverionRate() >= MINIMUM_USD,
            "You need to send some Ether. minimum 1 ETH"
        );
        // add to the array
        funders.push(msg.sender);
        // add to the mpping
        fundedAmountByFunder[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // rest the mapping
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            fundedAmountByFunder[funder] = 0;
        }
        // reset the funders array
        funders = new address[](0);
        // transfer the money

        //---- first way -----
        // msg.sender -> address
        // payable(msg.sender) -> payable adderss
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

    function getTotalAmoutOfFund() public view onlyOwner returns (uint256) {
        // add the value of all the mappinds in fundedAmountByFunder
        return address(this).balance;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getHowmanyFunders() public view returns (uint256) {
        return funders.length;
    }

    // if user do somthing accidentally fallback or receive to the fund function by defalt
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
