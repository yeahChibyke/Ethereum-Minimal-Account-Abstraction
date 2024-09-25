// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MinimalAbstractAccount} from "../src/MinimalAbstractAccount.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployMAA is Script {
    function run() public {
        deployMAA();
    }

    function deployMAA() public returns (HelperConfig, MinimalAbstractAccount) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.account);
        MinimalAbstractAccount maa = new MinimalAbstractAccount(config.entryPoint);
        maa.transferOwnership(msg.sender);
        vm.stopBroadcast();

        return (helperConfig, maa);
    }
}
