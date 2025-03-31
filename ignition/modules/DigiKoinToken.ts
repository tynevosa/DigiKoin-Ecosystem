// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DigiKoinModule", (m) => {
  // Deploy the DigiKoinToken contract
  const digiKoin = m.contract("DigiKoinToken");

  // Define Chainlink price feed addresses for Sepolia network
  const ethUsdFeed = m.getParameter(
    "ethUsdFeed",
    "0x694AA1769357215DE4FAC081bf1f309aDC325306"  // Sepolia default
  );

  const xauUsdFeed = m.getParameter(
    "xauUsdFeed",
    "0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea"  // Sepolia default
  );

  // Deploy the PriceFeed contract
  const priceFeed = m.contract("PriceFeed", [ethUsdFeed, xauUsdFeed]);

  // Reference the token & price feed contracts by passing them directly (no .address needed)
  const dividendManager = m.contract("DividendManager", [digiKoin]);
  const goldReserveManager = m.contract("GoldReserveManager", [digiKoin, priceFeed]);

  return { digiKoin, priceFeed, dividendManager, goldReserveManager };
});
