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

    // >>---(variables)--->
    uint256 constant ETH_MAIN_CHAIN_ID = 1;
    uint256 constant ETH_SEP_CHAIN_ID = 11155111;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant BURNER_WALLET = 0x25571828c3F5cdC6f57d124dccd65D1be7ECaA2e;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    NetworkConfig public localNetworkConfig;

    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    // >>---(constructor)--->
    constructor() {
        networkConfigs[ETH_SEP_CHAIN_ID] = getEthSepConfig();
        networkConfigs[ETH_MAIN_CHAIN_ID] = getEthMainConfig();
    }

    // >>---(functions)--->
    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HC__InvalidChain();
        }
    }

    function getEthMainConfig() public pure returns (NetworkConfig memory) {
        // This is v7
        return NetworkConfig({
            entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032,
            usdc: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            account: BURNER_WALLET
        });
        // https://blockscan.com/address/0x0000000071727De22E5E9d8BAf0edAc6f37da032}
    }

    function getEthSepConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            usdc: 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0,
            account: BURNER_WALLET
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        // mocks deploy
        console2.log("Deploying mocks in 3, 2, 1,... GO!!!!");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        EntryPoint entryPoint = new EntryPoint();
        ERC20Mock erc20Mock = new ERC20Mock();
        vm.stopBroadcast();
        console2.log("Mocks deployed LFG!!!");

        localNetworkConfig =
            NetworkConfig({entryPoint: address(entryPoint), usdc: address(erc20Mock), account: ANVIL_DEFAULT_ACCOUNT});
        return localNetworkConfig;
    }
}
