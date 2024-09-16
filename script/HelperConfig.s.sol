// SPDX-License-Identifier: MIT

//1. Deploy mocks when we are on a local anvil chain
//2. Keep track of contract address accross different chains
// Logically Sepolia ETH/USD - has different address than Mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig {
    //if we are on a local anvil, we deploy mocks
    //otherwise, grab the existing address from the live network

    NetowrkConfig public activeNetworkConfig;

    struct NetowrkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
        // else if {
        //     activeNetworkConfig.....
        // }
    }

    function getSepoliaEthConfig() public pure returns (NetowrkConfig memory) {
        //price feed address
        NetowrkConfig memory sepoliaConfig = NetowrkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public pure returns (NetowrkConfig memory) {
        //price feed address
    }
}
