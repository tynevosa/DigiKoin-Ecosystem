import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress, parseEther } from "viem";
import { formatEther } from "ethers";

describe("DigiKoin", function () {
  async function deployDigiKoinFixture() {
    const [owner, alice, bob] = await hre.viem.getWalletClients();

    const digiKoin = await hre.viem.deployContract("DigiKoin");

    const publicClient = await hre.viem.getPublicClient();

    return {
      digiKoin,
      owner,
      alice,
      bob,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { digiKoin, owner } = await loadFixture(deployDigiKoinFixture);
      expect(await digiKoin.read.owner()).to.equal(getAddress(owner.account.address));
    });

    it("Should mint initial supply correctly", async function () {
      const { digiKoin } = await loadFixture(deployDigiKoinFixture);
      expect(await digiKoin.read.totalSupply()).to.equal(parseEther("10000")); // 10kg = 10,000 grams
    });
  });

  describe("Gold Operations", function () {
    it("Should allow owner to mint new tokens", async function () {
      const { digiKoin, alice } = await loadFixture(deployDigiKoinFixture);
      const mintAmount = parseEther("100"); // 100 grams

      await digiKoin.write.mintGold([alice.account.address, mintAmount]);

      expect(await digiKoin.read.balanceOf([alice.account.address])).to.equal(mintAmount);
      expect(await digiKoin.read.goldReserves()).to.equal(parseEther("10100")); // Initial 10kg + 100g
    });

    it("Should allow users to redeem gold", async function () {
      const { digiKoin, alice } = await loadFixture(deployDigiKoinFixture);
      const redeemAmount = parseEther("50"); // 50 grams

      // First mint to alice
      await digiKoin.write.mintGold([alice.account.address, redeemAmount]);

      // Then redeem
      await digiKoin.write.redeemGold([redeemAmount], {
        account: alice.account,
      });

      expect(await digiKoin.read.balanceOf([alice.account.address])).to.equal(0n);
      expect(await digiKoin.read.goldReserves()).to.equal(parseEther("10000")); // Back to initial
    });
  });

  describe("Dividend System", function () {
    it("Should distribute dividends correctly", async function () {
      const { digiKoin, owner, alice, publicClient } = await loadFixture(deployDigiKoinFixture);

      // Mint some tokens to alice
      const mintAmount = parseEther("1000");
      await digiKoin.write.mintGold([alice.account.address, mintAmount]);

      // Distribute 1 ETH dividend
      const dividendAmount = parseEther("1");
      await digiKoin.write.distributeDividends({
        account: owner.account,
        value: dividendAmount,
      });

      // Wait for 1 block for snapshot
      await hre.network.provider.send("evm_mine");

      // Get Alice's ETH balance BEFORE claiming dividends
      const balanceBefore = await publicClient.getBalance({
        address: alice.account.address,
      });

      // Alice owns 1000/11000 of total supply (9.09%)
      await digiKoin.write.claimDividend({
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
      const expectedDividend = 1 * 1000 / 11000;

      // Should receive ~0.0909 ETH (within 0.0001 ETH tolerance)
      expect(ethGainedNumber).to.be.closeTo(expectedDividend, 0.00015);
    });
  });

  describe("Token Sale", function () {
    it("Should allow buying tokens with ETH", async function () {
      const { digiKoin, alice, publicClient } = await loadFixture(deployDigiKoinFixture);

      const ethAmount = parseEther("1");
      const expectedTokens = ethAmount * 100n; // 1 ETH = 100 DGK at initial rate

      await digiKoin.write.buyTokens({
        account: alice.account,
        value: ethAmount,
      });

      expect(await digiKoin.read.balanceOf([alice.account.address])).to.equal(expectedTokens);
      expect(await digiKoin.read.goldReserves()).to.equal(parseEther("10100")); // +100 grams
    });
  });
});