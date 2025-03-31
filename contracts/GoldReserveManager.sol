// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./DigiKoinToken.sol"; // Import the DigiKoinToken contract
import "./PriceFeed.sol"; // Import the PriceFeed contract

contract GoldReserveManager is Ownable, ReentrancyGuard {
    uint256 public constant TROY_OUNCE_IN_GRAMS_E10 = 3110352185; // 31.10352185 with 1e10 scaling
    using EnumerableSet for EnumerableSet.AddressSet;

    DigiKoinToken public digiKoin; // Reference to the DigiKoinToken contract
    PriceFeed public priceFeed; // Reference to the DigiKoinToken contract

    EnumerableSet.AddressSet private holders;

    event GoldHeld(address indexed recipient, uint256 amount);
    event GoldRedeemed(address indexed holder, uint256 amount);

    /**
     * @dev Constructor sets the DigiKoinToken contract address.
     */
    constructor(
        address digiKoinAddress,
        address priceFeedAddress
    ) Ownable(DigiKoinToken(digiKoinAddress).owner()) {
        require(digiKoinAddress != address(0), "Invalid address");
        digiKoin = DigiKoinToken(digiKoinAddress);
        priceFeed = PriceFeed(priceFeedAddress);
    }

    /**
     * @dev Helper function to calculate the ETH value for a given amount of gold
     * @param grams The amount of gold in grams
     * @return ethValue The ETH value
     */
    function calculateEthForGold(
        uint256 grams
    ) public view returns (uint256 ethValue) {
        require(address(priceFeed) != address(0), "Price feed not set");

        // Get XAU/USD price and ETH/USD price from the price feed
        uint256 xauUsdPrice = priceFeed.getXauPrice();
        uint256 ethUsdPrice = priceFeed.getEthPrice();

        // Convert grams to troy ounces (1 troy oz = 31.10352185 grams)
        uint256 troyOunces = (grams * 1e10) / TROY_OUNCE_IN_GRAMS_E10; // Scaled by 1e10 for precision

        // Calculate ETH value
        ethValue = (troyOunces * xauUsdPrice) / ethUsdPrice;

        return ethValue;
    }

    function holdGold(uint256 grams) external payable nonReentrant {
        require(grams > 0, "Amount must be positive");

        // Calculate required ETH
        uint256 requiredEth = calculateEthForGold(grams);

        // Check if sender sent enough ETH
        require(msg.value >= requiredEth, "Insufficient ETH sent");

        // Refund excess ETH if any
        if (msg.value > requiredEth) {
            payable(msg.sender).transfer(msg.value - requiredEth);
        }

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

        // Calculate ETH to transfer back to holder
        uint256 ethToReturn = calculateEthForGold(grams);

        // Check contract has enough ETH
        require(
            address(this).balance >= ethToReturn,
            "Insufficient ETH in contract"
        );

        // Transfer tokens from holder back to the DigiKoin contract
        digiKoin.redeem(msg.sender, grams);

        // Remove holder if they no longer have any tokens
        if (digiKoin.balanceOf(msg.sender) == 0) {
            holders.remove(msg.sender);
        }

        // Transfer ETH to the holder
        payable(msg.sender).transfer(ethToReturn);

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

    /**
     * @dev Updates the PriceFeed contract address (only by owner).
     */
    function setPriceFeedContract(address newAddress) external onlyOwner {
        require(newAddress != address(0), "Invalid address");
        priceFeed = PriceFeed(newAddress);
    }
}
