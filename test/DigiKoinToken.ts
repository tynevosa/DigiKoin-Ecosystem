import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { formatEther, getAddress, parseEther } from "viem";

describe("DigiKoin Ecosystem Test", function () {
  const TOTAL_SUPPLY = parseEther("10000");  // 10kg = 10,000 grams

  async function deployDigiKoinFixture() {
    const [owner, alice, bob] = await hre.viem.getWalletClients();

    const digiKoin = await hre.viem.deployContract("DigiKoinToken");
    const dividendManager = await hre.viem.deployContract("DividendManager", [digiKoin.address]);
    const goldReserveManager = await hre.viem.deployContract("GoldReserveManager", [digiKoin.address]);

    const publicClient = await hre.viem.getPublicClient();

    return {
      digiKoin,
      dividendManager,
      goldReserveManager,
      owner,
      alice,
      bob,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { digiKoin, dividendManager, goldReserveManager, owner } = await loadFixture(deployDigiKoinFixture);
      expect(await digiKoin.read.owner()).to.equal(getAddress(owner.account.address));
      expect(await dividendManager.read.owner()).to.equal(getAddress(owner.account.address));
      expect(await goldReserveManager.read.owner()).to.equal(getAddress(owner.account.address));
    });

    it("Should mint initial supply correctly", async function () {
      const { digiKoin } = await loadFixture(deployDigiKoinFixture);
      expect(await digiKoin.read.totalSupply()).to.equal(TOTAL_SUPPLY); // 10kg = 10,000 grams
    });
  });

  describe("Gold Reserve", function () {
    it("Should allow owner to mint new tokens", async function () {
      const { digiKoin, goldReserveManager, alice, bob } = await loadFixture(deployDigiKoinFixture);
      const goldAmount = parseEther("100"); // 100 grams

      await goldReserveManager.write.holdGold([goldAmount], {
        account: alice.account,
      });

      expect(await digiKoin.read.balanceOf([alice.account.address])).to.equal(goldAmount);
      expect(await digiKoin.read.balanceOf([digiKoin.address])).to.equal(TOTAL_SUPPLY - goldAmount); // 10kg - 100g

      await digiKoin.write.transfer([bob.account.address, goldAmount], {
        account: alice.account
      })

      expect(await digiKoin.read.balanceOf([alice.account.address])).to.equal(0n);
      expect(await digiKoin.read.balanceOf([bob.account.address])).to.equal(goldAmount);

      await goldReserveManager.write.redeemGold([goldAmount], {
        account: bob.account,
      })

      expect(await digiKoin.read.balanceOf([bob.account.address])).to.equal(0n);
      expect(await digiKoin.read.balanceOf([digiKoin.address])).to.equal(TOTAL_SUPPLY); // Back to initial 10kg
    });
  });

  describe("Dividend System", function () {
    it("Should distribute dividends correctly", async function () {
      const { dividendManager, goldReserveManager, owner, alice, publicClient } = await loadFixture(deployDigiKoinFixture);

      // Alice holds 1 kg gold
      const goldAmount = parseEther("1000");
      await goldReserveManager.write.holdGold([goldAmount], {
        account: alice.account,
      });

      // Distribute 1 ETH dividend
      const dividendAmount = parseEther("1");
      await dividendManager.write.distributeDividends({
        account: owner.account,
        value: dividendAmount,
      });

      // Wait for 1 block for snapshot
      await hre.network.provider.send("evm_mine");

      // Get Alice's ETH balance BEFORE claiming dividends
      const balanceBefore = await publicClient.getBalance({
        address: alice.account.address,
      });

      // Alice owns 1 kg / 10 kg of total supply (10%)
      await dividendManager.write.claimDividend({
        account: alice.account,
      });

      // ✅ Get Alice's ETH balance AFTER claiming dividends
      const balanceAfter = await publicClient.getBalance({
        address: alice.account.address,
      });

      // ✅ Calculate only the ETH gained
      const ethGained = balanceAfter - balanceBefore;

      // 🛠️ Convert bigint to number for the assertion
      const ethGainedNumber = parseFloat(formatEther(ethGained));
      const expectedDividend = 1 * 1000 / 10000;

      // Should receive ~0.0909 ETH (within 0.0001 ETH tolerance)
      expect(ethGainedNumber).to.be.closeTo(expectedDividend, 0.0001);
    });
  });
});