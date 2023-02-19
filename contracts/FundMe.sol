// Get funds from users
// withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

/**
 * @title A contract for crowd funding
 * @author myself:)
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    //uint256 public number;
    uint256 public constant MINIMUM_USD = 50 * 1e18; //constant because it is assigned once at compile time and never changes.
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner; //immutable = variables that we set one time but outside of where they have been declared (see constructor)
    AggregatorV3Interface private s_priceFeed;

    // constant and immutable variables are directly stored in the bytecode instead of a storage slot => cheaper
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    address[] private s_funders;

    function fund() public payable {
        //want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract? (value parameter in Remix!)
        //number = 5;
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough!"
        );
        // require(getConversionRate(msg.value) >= MINIMUM_USD, "Didn't send enough!"); //1e18== 1* 10**18
        //if require is not met any prior work will be undone => however we have to pay the gas for computations afterwards.
        // 18 decimals
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        /*starting index, ending index, step amount */
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex = funderIndex + 1
        ) {
            // or funderIndex++
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0); //brand new funders array with 0 objects in it
        // actually withdraw the funds

        //transfer, send, call. --> transfer to whoever is calling the function withdraw

        //msg.sender = type of address
        //payable(msg.sender) = payable address
        payable(msg.sender).transfer(address(this).balance);
        //transfer is capped at 2300 gas => throws an error if it goes above. => transfer automatically reverts if the transfer fails.
        //send is also capped at 2300 gas => if it fails it returns a boolean. => with send it won't throw an error. it returns a bool whether it was successfull or not
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed"); // send only reverts the transaction if we add a require statement.
        // call
        // with call we can call functions without even having the ABI.
        (bool callSuccess /*bytes memory dataReturned*/, ) = payable(msg.sender)
            .call{value: address(this).balance}(""); //blank "" if we do not want to call any function
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    //receive and fallback are useful when someone sends funds to our contract accidentaly without calling directly the fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
