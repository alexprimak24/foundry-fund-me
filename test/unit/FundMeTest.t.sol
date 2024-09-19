// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant GAS_PRICE = 1;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    //this function is responsible for deploying contract

    function setUp() external {
        //us are calling -> FundMeTest deployes -> FundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //there we are sending some fake ether to out fake user
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinumumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
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
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //it says that the next code should fainl
        // something like assert(this tx fails/reverts)
        fundMe.fund(); //send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        //there we are assuming that the next tsx will be sent by that user
        vm.prank(USER); //The next TX will be sent by USER
        // there our contract calls the function fundMe
        fundMe.fund{value: SEND_VALUE}();

        //there we get an amount that out contract funded to FundMe
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);

        assertEq(funder, USER);
    }

    //so as I will progress I will write really complex tests and to make my tests more
    //readable and better structures, the best practise is to just use modifiers.
    modifier funded() {
        //there we are funding our FundMe from USER
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //then we expect that the call will be reverted
        vm.expectRevert();
        //we are trying to call withdraw function from USER
        vm.prank(USER);
        fundMe.withdraw();

        //so consiquently it will revert as USER != Owner
    }

    function testWithdrawWithASingleFunder() public funded {
        //so in tests you usually arrange something (funding contract for example)
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            // address()
            //we are creating a black address and send some funds into it
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // the way how to check out how much gas we spent
        uint256 gasStart = gasleft(); //let's pretend we sent 1000 gas
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner()); // we used 200 gas
        fundMe.withdraw(); // we should have spent gas right?
        //the thing is if we are working with Anvil chain - gas price default to 0
        //so that the Assert below works just fine
        vm.stopPrank();

        uint256 gasEnd = gasleft(); //left 800 gas
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            //vm.deal new address
            // address()
            //we are creating a black address and send some funds into it
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // the way how to check out how much gas we spent
        uint256 gasStart = gasleft(); //let's pretend we sent 1000 gas
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner()); // we used 200 gas
        fundMe.cheaperWithdraw(); // we should have spent gas right?
        //the thing is if we are working with Anvil chain - gas price default to 0
        //so that the Assert below works just fine
        vm.stopPrank();

        uint256 gasEnd = gasleft(); //left 800 gas
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}
