// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DigiKoin (DGK) – A Gold-Backed Digital Token
 * @dev Each DGK token is pegged to 1 gram of physical gold.
 * Features:
 * - 1 DGK = 1 gram gold (10,000 DGK = 10 kg gold reserve)
 * - Dividend distribution for token holders
 * - Equity investment opportunities
 * - Secure redemption mechanism
 * - Reentrancy protection
 */
contract DigiKoin is ERC20, ERC20Permit, ERC20Votes, Ownable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Token & Gold Constants
    uint256 public constant TOKENS_PER_GRAM = 1 * 10 ** 18; // 1 DGK = 1 gram (18 decimals)
    uint256 public constant TOTAL_GOLD_RESERVE = 10000 * TOKENS_PER_GRAM; // 10,000 grams (10 kg)

    // State Variables
    uint256 public goldReserves; // Tracks physical gold (grams)
    uint256 public totalDividends;
    uint256 public totalEquity;
    uint256 public ethPerTokenRate = 0.01 ether; // 1 DGK = 0.01 ETH (adjustable)

    // Mappings
    mapping(address => uint256) public equityStake;
    // Dividend System
    struct DividendPeriod {
        uint256 totalShare;
        uint256 blockNumber;
        uint256 totalSupply;
    }
    DividendPeriod[] public dividendPeriods;
    mapping(address => uint256) private lastDividendClaim;
    EnumerableSet.AddressSet private holders;

    // Events
    event GoldMinted(address indexed recipient, uint256 amount);
    event GoldRedeemed(address indexed user, uint256 amount);
    event DividendsDistributed(uint256 amount);
    event DividendClaimed(address indexed user, uint256 amount);
    event EquityPurchased(address indexed user, uint256 amount);
    event ExchangeRateUpdated(uint256 newRate);

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    constructor()
        ERC20("DigiKoin", "DGK")
        ERC20Permit("DigiKoin")
        Ownable(msg.sender)
    {
        goldReserves = TOTAL_GOLD_RESERVE;
        _mint(msg.sender, TOTAL_GOLD_RESERVE); // Initial supply = 10 kg gold
    }

    //───────────────────────//
    //      CORE FUNCTIONS   //
    //───────────────────────//

    /**
     * @dev Mints new DGK tokens (owner-only).
     * Requires actual gold reserve increase.
     */
    function mintGold(address recipient, uint256 grams) external onlyOwner {
        require(grams > 0, "Amount must be positive");
        goldReserves += grams;
        _mint(recipient, grams);
        _delegate(recipient, recipient);
        holders.add(recipient);
        emit GoldMinted(recipient, grams);
    }

    /**
     * @dev Redeems DGK for physical gold (1 DGK = 1 gram).
     * Burns tokens and reduces gold reserves.
     */
    function redeemGold(uint256 tokens) external nonReentrant {
        require(balanceOf(msg.sender) >= tokens, "Insufficient balance");
        require(tokens <= goldReserves, "Not enough gold reserves");

        _burn(msg.sender, tokens);
        goldReserves -= tokens;
        if (balanceOf(msg.sender) == 0) {
            holders.remove(msg.sender);
        }
        emit GoldRedeemed(msg.sender, tokens);
    }

    //───────────────────────//
    //   DIVIDEND SYSTEM     //
    //───────────────────────//

    /**
     * @dev Distributes dividends proportionally to token holders.
     */
    function distributeDividends() external payable onlyOwner {
        require(msg.value > 0, "Dividend amount must be > 0");
        require(totalSupply() > 0, "No tokens in circulation");

        dividendPeriods.push(
            DividendPeriod({
                totalShare: msg.value,
                blockNumber: block.number,
                totalSupply: totalSupply()
            })
        );

        totalDividends += msg.value;
        emit DividendsDistributed(msg.value);
    }

    /**
     * @dev Allows users to claim accumulated dividends.
     */
    function claimDividend() external nonReentrant {
        uint256 unclaimedDividends;
        for (
            uint256 i = lastDividendClaim[msg.sender];
            i < dividendPeriods.length;
            i++
        ) {
            unclaimedDividends +=
                (getPastVotes(msg.sender, dividendPeriods[i].blockNumber) *
                    dividendPeriods[i].totalShare) /
                dividendPeriods[i].totalSupply;
        }

        require(unclaimedDividends > 0, "No dividends available");
        lastDividendClaim[msg.sender] = dividendPeriods.length;

        (bool success, ) = payable(msg.sender).call{value: unclaimedDividends}(
            ""
        );
        require(success, "Transfer failed");

        emit DividendClaimed(msg.sender, unclaimedDividends);
    }

    //───────────────────────//
    //   TOKEN SALE & EQUITY //
    //───────────────────────//

    /**
     * @dev Buy DGK tokens with ETH at the current rate.
     */
    function buyTokens() external payable nonReentrant {
        require(msg.value > 0, "ETH amount must be > 0");
        uint256 tokens = (msg.value * 1e18) / ethPerTokenRate;

        _mint(msg.sender, tokens);
        _delegate(msg.sender, msg.sender);
        holders.add(msg.sender);
        goldReserves += tokens;
        emit GoldMinted(msg.sender, tokens);
    }

    /**
     * @dev Allows users to invest in DigiKoin equity.
     */
    function buyEquity() external payable nonReentrant {
        require(msg.value > 0, "ETH amount must be > 0");
        equityStake[msg.sender] += msg.value;
        totalEquity += msg.value;
        emit EquityPurchased(msg.sender, msg.value);
    }

    //───────────────────────//
    //   ADMIN FUNCTIONS     //
    //───────────────────────//

    /**
     * @dev Updates the ETH/DGK exchange rate (owner-only).
     */
    function updateExchangeRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Rate must be > 0");
        ethPerTokenRate = newRate;
        emit ExchangeRateUpdated(newRate);
    }

    /**
     * @dev Withdraws contract ETH (owner-only).
     */
    function withdrawEther(uint256 amount) external onlyOwner nonReentrant {
        require(amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Withdrawal failed");
    }
}
