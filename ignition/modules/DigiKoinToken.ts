// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { parseEther } from "viem";

export default buildModule("DigiKoinModule", (m) => {
  // Deploy the DigiKoinToken contract
  const digiKoin = m.contract("DigiKoinToken");

  // Reference the token contract by passing it directly (no .address needed)
  const dividendManager = m.contract("DividendManager", [digiKoin]);
  const goldReserveManager = m.contract("GoldReserveManager", [digiKoin]);

  return { digiKoin, dividendManager, goldReserveManager };
});
