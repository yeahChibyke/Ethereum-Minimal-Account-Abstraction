// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAbstractAccount is IAccount, Ownable {
    // >>---(errors)--->
    error MAA__NotFromEntryPoint();
    error MAA__NotFromEntryPointOrOwner();
    error MAA__CallFailed(bytes);

    // >>---(variables)--->
    IEntryPoint private immutable i_entryPoint;

    // >>---(modifiers)--->
    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MAA__NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender == owner()) {
            revert MAA__NotFromEntryPointOrOwner();
        }
        _;
    }

    // >>---(constructor)--->
    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    // >>---(receive)--->
    receive() external payable {}

    // >>---(external functions)--->
    // A signature is valid if it is the MinimalAbstractAccount owner
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    function execute(address destination, uint256 value, bytes calldata functionData)
        external
        requireFromEntryPointOrOwner
    {
        (bool success, bytes memory result) = destination.call{value: value}(functionData);
        if (!success) {
            revert MAA__CallFailed(result);
        }
    }

    // >>---(internal functions)--->
    // EIP-191 of the signed hash
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }

    // >>---(getters)--->
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}
