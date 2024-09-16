// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        //actually we should do it that way, but it works fine in our case without ()
        //as we are passing just one parameter
        // (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        //by this line we like say: Everything that is after this line should be sent to an RPC
        vm.startBroadcast();
        //`new` creates new contract
        //by this approach msg.sender is the deployer of the contract
        //Mock
        FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
        return fundMe;
    }
}
