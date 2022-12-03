// SPDX-License-Identifier: MIT
// Pragma
pragma solidity 0.8.8;
// Imports
import "./PriceConverter.sol";

// Error Codes
error FundMe__NotOwner();

// Interfaces, Libraries, Contracts

/** @title A contract for crowd funding
 *  @author chinhnd7
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
    // Get funds from users
    // Withdraw funds
    // Set a minimum funding value in USD

    // Type declarations
    using PriceConverter for uint256;

    // State Variables!
    uint256 public constant MINIMUM_USD = 5 * 1e18; // 5USD
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    // Function Modifiers are used to modify the behaviour of a function
    // It can be used to​​ validate the owner or validate the value of an action.
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");

        // // run require first, run function after
        // // If "_" is before "require" command, it runs commands in the function first.
        // _;
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // What happens if someone sends this contract ETH without calling the fund function
    // If someone send ETH (from metamask), we have to call fund() function because they are funders
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract?
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough!"
        ); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset the array
        s_funders = new address[](0);

        // // actually withdraw the funds

        // // transfer
        // // Transfer automatically reverts if the transfer fails
        // payable(msg.sender).transfer(address(this).balance);
        // // msg.sender : address of sender - 0xd795C5458572F5958DA0Ba915EA380b581C5f316
        // // address(this): address of contract
        // // address(this).balance : balance of contract

        // // send
        // // Send will only revert the transaction if we add the require statement
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed!");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        // return 2 variables but only care about 1
        require(callSuccess, "Call failed!");
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    // Concepts we didn't cover yet (will cover in later sections)
    // 1. Enum
    // 2. Events
    // 3. Try / Catch
    // 4. Function Selector
    // 5. abi.encode / decode
    // 6. Hash with keccak256
    // 7. Yul / Assembly

    // function getFunder(uint256 index) public view returns (address) {
    //     return s_funders[index];
    // }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        // return 2 variables but only care about 1
        require(callSuccess, "Call failed!");
    }

    // View / Pure
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
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
