// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    //this function is responsible for deploying contract

    function setUp() external {
        //us are calling -> FundMeTest deployes -> FundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinumumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }
    // What can we do to work with addresses outside our system?
    // 1. Unit
    //     -testing a specific part of our code
    // 2. Integration
    //     -testing how our code works with other parts of our code
    // 3. Forked
    //     - testing out code on a simulated real environment
    // 4. Staging
    //     - testing out code in a real environment that is not prod

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version,4);
    }
}
