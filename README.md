# DigiKoin Token Smart Contract Project

## 📌 **Overview**
The **DigiKoin Token** (DGK) project is a Solidity-based smart contract ecosystem that implements:
- An **ERC20 token** backed by gold reserves (1 DGK = 1 gram of gold)
- **Governance and voting** functionalities using ERC20Votes
- **Dividend distribution** to token holders
- A **gold reserve manager** to handle the holding and redemption of gold-backed tokens
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
- Manages **gold-backed holdings** and redemptions.
- Uses `EnumerableSet` to track DGK holders.
- Key functions:
    - `holdGold()`: Transfers DGK tokens from the contract to the sender.
    - `redeemGold()`: Allows users to redeem their DGK tokens.
- Emits events:
    - `GoldHeld`: When a user holds gold-backed DGK tokens.
    - `GoldRedeemed`: When a user redeems DGK tokens.

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
Deploy to Sepolia:
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

---

## 🔒 **Security Considerations**
- **ReentrancyGuard** is used to prevent reentrancy attacks.
- **Ownable** modifier ensures only the contract owner can perform privileged operations.
- Proper balance checks and require statements to avoid invalid transfers.

---

## 📚 **Technologies Used**
- **Solidity:** v0.8.28
- **OpenZeppelin:** ERC20, ERC20Votes, Ownable, and ReentrancyGuard
- **Hardhat:** Local testing and deployment
- **TypeScript:** Configuration and deployment scripts

---

## 📌 **Folder Structure**
```
/contracts
 ├── DigiKoinToken.sol        # Main ERC20 token contract
 ├── DividendManager.sol      # Manages dividend distribution
 └── GoldReserveManager.sol   # Manages gold reserves
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
