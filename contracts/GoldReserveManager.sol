// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./DigiKoinToken.sol"; // Import the DigiKoinToken contract

contract GoldReserveManager is Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    DigiKoinToken public digiKoin; // Reference to the DigiKoinToken contract

    EnumerableSet.AddressSet private holders;

    event GoldHeld(address indexed recipient, uint256 amount);
    event GoldRedeemed(address indexed holder, uint256 amount);

    /**
     * @dev Constructor sets the DigiKoinToken contract address.
     */
    constructor(
        address digiKoinAddress
    ) Ownable(DigiKoinToken(digiKoinAddress).owner()) {
        require(digiKoinAddress != address(0), "Invalid address");
        digiKoin = DigiKoinToken(digiKoinAddress);
    }

    function holdGold(uint256 grams) external nonReentrant {
        require(grams > 0, "Amount must be positive");

        // Ensure the DigiKoin contract has enough tokens
        require(
            digiKoin.balanceOf(address(digiKoin)) >= grams,
            "Insufficient contract balance"
        );

        // Transfer tokens from the DigiKoin contract to the sender
        require(digiKoin.hold(msg.sender, grams), "Transfer failed");

        holders.add(msg.sender);
        emit GoldHeld(msg.sender, grams);
    }

    function redeemGold(uint256 grams) external nonReentrant {
        require(
            digiKoin.balanceOf(msg.sender) >= grams,
            "Insufficient balance"
        );

        digiKoin.redeem(msg.sender, grams);
        if (digiKoin.balanceOf(msg.sender) == 0) {
            holders.remove(msg.sender);
        }

        emit GoldRedeemed(msg.sender, grams);
    }

    /**
     * @dev Updates the DigiKoinToken contract address (only by owner).
     */
    function setDigiKoinTokenContract(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid address");
        digiKoin = DigiKoinToken(newAddress);
        transferOwnership(digiKoin.owner()); // Sync ownership
    }
}
