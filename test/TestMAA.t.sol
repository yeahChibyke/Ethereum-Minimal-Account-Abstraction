// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {MinimalAbstractAccount} from "../src/MinimalAbstractAccount.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployMAA} from "../script/DeployMAA.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
// // import {SendPackedUserOp, PackedUserOperation, IEntryPoint} from "/script/SendPackedUserOp.s.sol";
// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TestMAA is Test {
    MinimalAbstractAccount maa;
    HelperConfig helperConfig;
    DeployMAA deployer;
    ERC20Mock usdc;

    uint256 constant MINT_AMOUNT = 10e18;

    function setUp() public {
        deployer = new DeployMAA();
        (helperConfig, maa) = deployer.deployMAA();
        usdc = new ERC20Mock();
    }

    function testOwnerCanExecuteCommands() public {
        // Arrange
        assert(usdc.balanceOf(address(maa)) == 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(maa), MINT_AMOUNT);

        // Act
        vm.prank(maa.owner());
        maa.execute(destination, value, functionData);

        // Assert
        assert(usdc.balanceOf(address(maa)) == MINT_AMOUNT);
    }

    function testPrankOwnerCannotExecuteCommands() public {
        // Arrange
        assert(usdc.balanceOf(address(maa)) == 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(maa), MINT_AMOUNT);

        address prankOwner = makeAddr("prankOwner");

        // Act
        vm.prank(prankOwner);
        vm.expectRevert(MinimalAbstractAccount.MAA__NotFromEntryPointOrOwner.selector);
        maa.execute(destination, value, functionData);

        // Assert
        assert(usdc.balanceOf(prankOwner) == 0);
    }
}
