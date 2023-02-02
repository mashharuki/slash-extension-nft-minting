// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ISlashCustomPlugin.sol";
import "./libs/UniversalERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * interface
 */
interface IERC721Demo {
    function mint(address to) external returns (uint256);
}

/**
 * MintExtension Contract
 */
contract MintExtension is ISlashCustomPlugin, Ownable {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;
    // デモ用のNFTのコントラクトアドレスを格納する変数
    IERC721Demo private nftDemo;

    mapping(string => string) public purchaseInfo;

    event TokenWithdrawn(address tokenContract, uint256 amount);

    /**
     * updateNftContractAddress fumction
     */
    function updateNftContractAddress(address nftContractAddress)
        external
        onlyOwner
    {
        nftDemo = IERC721Demo(nftContractAddress);
    }

    /**
     * receivePayment function
     */
    function receivePayment(
        address receiveToken,
        uint256 amount,
        string memory paymentId,
        string memory optional
    ) external payable override {
        require(amount > 0, "invalid amount");
        require(receiveToken != address(0), "invalid token");
        // 呼び出し元からownerのアドレスにamount分だけ送信する。
        IERC20(receiveToken).universalTransferFrom(msg.sender, owner(), amount);
        // do something
        afterReceived(paymentId, optional);
    }

    /**
     * NFTを発行する。
     */
    function afterReceived(string memory paymentId, string memory optional)
        internal
    {
        uint256 tokenId = nftDemo.mint(tx.origin);
        purchaseInfo[paymentId] = optional;
    }

    function withdrawToken(address tokenContract) external onlyOwner {
        require(
            IERC20(tokenContract).universalBalanceOf(address(this)) > 0,
            "balance is zero"
        );

        IERC20(tokenContract).universalTransfer(
            msg.sender,
            IERC20(tokenContract).universalBalanceOf(address(this))
        );

        emit TokenWithdrawn(
            tokenContract,
            IERC20(tokenContract).universalBalanceOf(address(this))
        );
    }

    /**
     * @dev Check if the contract is Slash Plugin
     *
     * Requirement
     * - Implement this function in the contract
     * - Return true
     */
    function supportSlashExtensionInterface()
        external
        pure
        override
        returns (bool)
    {
        return true;
    }
}
