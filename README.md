# DigiKoin Token Smart Contract Project

## 📌 **Overview**
The **DigiKoin Token** (DGK) project is a Solidity-based smart contract ecosystem that implements:
- An **ERC20 token** backed by gold reserves (1 DGK = 1 gram of gold)
- **Governance and voting** functionalities using ERC20Votes
- **Dividend distribution** to token holders
- A **gold reserve manager** to handle the holding and redemption of gold-backed tokens
- **Real-time pricing** using Chainlink price feeds for ETH/USD and XAU/USD
- Integration with **Hardhat** for local testing and deployment

---

## 🔥 **Features**
### ✅ **DigiKoinToken.sol**
- ERC20 token with governance and permit functionalities.
- **Gold-backed supply**: 10,000 DGK (equivalent to 10 kg of gold).
- Custom `hold()` and `redeem()` functions:
    - `hold()` transfers DGK tokens to a recipient and automatically delegates voting power.
    - `redeem()` transfers DGK tokens back to the contract and revokes voting delegation.
- Events:
    - `TokensTransferredAndDelegated`: Emits when tokens are transferred and delegated.
    
### ✅ **DividendManager.sol**
- Enables the **distribution of dividends** in ETH to DGK holders.
- Keeps track of dividend periods:
    - `distributeDividends()` allows the contract owner to distribute ETH dividends.
    - `claimDividend()` enables token holders to claim their share of the dividends.
- Ownership and reentrancy protection.

### ✅ **GoldReserveManager.sol**
- Manages **gold-backed holdings** and redemptions with real-time pricing.
- Uses `EnumerableSet` to track DGK holders.
- **Dynamic ETH/gold conversion** using Chainlink price feeds.
- Key functions:
    - `holdGold()`: Allows users to purchase gold-backed tokens with ETH at current market rates.
    - `redeemGold()`: Allows users to redeem their DGK tokens for ETH at current market rates.
    - `calculateEthForGold()`: Helper function that computes ETH value of gold based on current prices.
- Emits events:
    - `GoldHeld`: When a user holds gold-backed DGK tokens.
    - `GoldRedeemed`: When a user redeems DGK tokens.

### ✅ **PriceFeed.sol**
- Integrates with **Chainlink oracles** for real-time price data.
- Provides current ETH/USD and XAU/USD (gold) prices.
- Includes fallback mechanism for price feed failures.
- Functions:
    - `getEthPrice()`: Returns the current ETH price in USD.
    - `getXauPrice()`: Returns the current gold (XAU) price in USD.

---

## 🛠️ **Setup and Installation**
1. **Clone the repository**
   ```bash
   git clone https://github.com/tynevosa/DigiKoin-Ecosystem.git
   cd DigiKoin-Ecosystem
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create a `.env` file**
   - Add your private key for Sepolia network deployment.
   ```
   PRIVATE_KEY=<your-wallet-private-key>
   ```

4. **Compile the contracts**
   ```bash
   npm run compile
   ```

5. **Run local tests**
   ```bash
   npm run test
   ```

---

## 🚀 **Deployment**
### ✅ **Local Deployment**
Start a local Hardhat node:
```bash
npx hardhat node
```

Deploy the contracts:
```bash
npm run deploy:local
```

### ✅ **Sepolia Testnet Deployment**
Deploy to Sepolia (uses Chainlink price feeds for Sepolia):
```bash
npm run deploy:sepolia
```

---

## 🧪 **Testing**
To run the Hardhat test suite:
```bash
npm run test
```

---

## 📄 **Contract Addresses**
- **DigiKoinToken:** `0x...`
- **DividendManager:** `0x...`
- **GoldReserveManager:** `0x...`
- **PriceFeed:** `0x...`

**Chainlink Price Feeds (Sepolia):**
- **ETH/USD:** `0x694AA1769357215DE4FAC081bf1f309aDC325306`
- **XAU/USD:** `0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea`

---

## 🔒 **Security Considerations**
- **ReentrancyGuard** is used to prevent reentrancy attacks.
- **Ownable** modifier ensures only the contract owner can perform privileged operations.
- Proper balance checks and require statements to avoid invalid transfers.
- **Fallback pricing** in case Chainlink oracles are unavailable.

---

## 📚 **Technologies Used**
- **Solidity:** v0.8.28
- **OpenZeppelin:** ERC20, ERC20Votes, Ownable, and ReentrancyGuard
- **Chainlink:** Price feed oracles for ETH/USD and XAU/USD data
- **Hardhat:** Local testing and deployment
- **Hardhat Ignition:** For structured contract deployment
- **TypeScript:** Configuration and deployment scripts

---

## 📌 **Folder Structure**
```
/contracts
 ├── DigiKoinToken.sol        # Main ERC20 token contract
 ├── DividendManager.sol      # Manages dividend distribution
 ├── GoldReserveManager.sol   # Manages gold reserves
 └── PriceFeed.sol            # Chainlink oracle integration for price data
/ignition
 └── modules
  └── DigiKoinToken.ts        # Ignition deployment module
/hardhat.config.ts            # Hardhat configuration
```

---

## 🔗 **License**
This project is licensed under the MIT License.

---

## 🚀 **Future Improvements**
- Implement **staking** mechanisms for DGK tokens.
- Add **chainlink oracle** integration for real-time gold pricing.
- Extend the governance functionality to include **DAO-based voting**.

---

✅ **Authors:**  
- Leonel Lasso
- 💡 Contact: leonel@voltedgetechsolutions.co.za  
