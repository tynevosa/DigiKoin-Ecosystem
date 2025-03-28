// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DigiKoinToken.sol"; // Import the DigiKoinToken contract

contract DividendManager is Ownable, ReentrancyGuard {
    DigiKoinToken public digiKoin; // Reference to the DigiKoinToken contract

    struct DividendPeriod {
        uint256 totalShare;
        uint256 blockNumber;
    }
    uint256 public totalDividends;
    DividendPeriod[] public dividendPeriods;
    mapping(address => uint256) private lastDividendClaim;

    event DividendsDistributed(uint256 amount);
    event DividendClaimed(address indexed user, uint256 amount);

    /**
     * @dev Constructor sets the DigiKoinToken contract address.
     */
    constructor(
        address digiKoinAddress
    ) Ownable(DigiKoinToken(digiKoinAddress).owner()) {
        require(digiKoinAddress != address(0), "Invalid address");
        digiKoin = DigiKoinToken(digiKoinAddress);
    }

    /**
     * @dev Distributes dividends using the DigiKoinToken totalSupply().
     */
    function distributeDividends() external payable onlyOwner {
        require(msg.value > 0, "Dividend amount must be > 0");
        require(digiKoin.totalSupply() > 0, "No tokens in circulation");

        dividendPeriods.push(
            DividendPeriod({totalShare: msg.value, blockNumber: block.number})
        );

        totalDividends += msg.value;
        emit DividendsDistributed(msg.value);
    }

    /**
     * @dev Allows token holders to claim their dividends.
     */
    function claimDividend() external nonReentrant {
        uint256 unclaimedDividends = 0;

        for (
            uint256 i = lastDividendClaim[msg.sender];
            i < dividendPeriods.length;
            i++
        ) {
            unclaimedDividends += ((digiKoin.balanceOf(msg.sender) *
                dividendPeriods[i].totalShare) / digiKoin.totalSupply());
        }

        require(unclaimedDividends > 0, "No dividends available");

        lastDividendClaim[msg.sender] = dividendPeriods.length;

        (bool success, ) = payable(msg.sender).call{value: unclaimedDividends}(
            ""
        );
        require(success, "Transfer failed");

        emit DividendClaimed(msg.sender, unclaimedDividends);
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
