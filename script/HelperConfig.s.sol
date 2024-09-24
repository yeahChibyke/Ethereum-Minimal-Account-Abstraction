// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    // >>---(errors)--->
    error HC__InvalidChain();

    // >>---(types)--->
    struct NetworkConfig {
        address entryPoint;
        address usdc;
        address account;
    }
}
