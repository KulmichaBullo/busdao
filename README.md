# 🚌⚡ BusDAO

**Community-owned electric matatus & buses on Initia blockchain. Green transport, fractional ownership, real profits.**

## 🌍 The Problem
- Africa's public transport is dominated by dirty diesel matatus — choking cities, killing health
- Electric buses cost $15K-$250K — only big players can afford the switch
- Current SACCO model is opaque — investors can't verify earnings
- Small investors and diaspora have no way to fund the green transition

## ⚡ The Solution
BusDAO lets anyone invest in **electric matatus and buses** through tokenized ownership on Initia blockchain. Community-owned green transport with transparent revenue distribution.

**Own a piece of Nairobi's electric future — for as little as $10.**

## 🟢 How It Works
1. **Invest** — Buy BUS tokens with stablecoins
2. **Vote** — DAO votes to purchase an electric matatu/bus
3. **Route** — DAO votes which route, vehicle joins SACCO
4. **Operate** — Normal operations (driver + conductor, cash/M-Pesa fares)
5. **Earn** — Revenue distributed to token holders weekly/monthly
6. **Impact** — Every vehicle on the road = less diesel, cleaner air, greener city

## 🌱 Why Electric?
- **Cost savings:** EVs cost 60-70% less to fuel and maintain than diesel
- **Health:** Nairobi's air quality crisis needs clean transport now
- **Profit:** Lower operating costs = higher returns for DAO members
- **Future:** Kenya is moving to EV mandates — early movers win
- **Story:** African green transport funded by African communities

## 🏗️ Architecture (Initia MiniEVM)
| Contract | Purpose |
|----------|---------|
| **BUSToken (ERC20)** | Fractional ownership token — your % = your share of profits |
| **BusDAOTreasury** | Holds funds, manages electric vehicle purchases |
| **ProfitDistributor** | Receives revenue, splits to holders weekly/monthly |
| **Governance** | Token-weighted voting on vehicle purchases, routes, SACCOs |

## 🛠️ Tech Stack
- **Blockchain:** Initia (MiniEVM rollup on testnet)
- **Smart Contracts:** Solidity + Foundry
- **Frontend:** React + ethers.js
- **Network:** Initia testnet (initiation-2)

## 📁 Project Structure
```
busdao/
├── contracts/          # Solidity smart contracts
│   ├── BUSToken.sol
│   ├── BusDAOTreasury.sol
│   ├── ProfitDistributor.sol
│   └── Governance.sol
├── frontend/           # React dApp
├── deploy/             # Deployment scripts
├── test/               # Contract tests
└── docs/               # Documentation
```

## ⏰ Timeline (Hackathon — 5 Days)
| Day | Deliverable |
|-----|-------------|
| 1 | Deploy MiniEVM rollup on Initia testnet |
| 2 | Smart contracts deployed |
| 3 | Frontend: invest, dashboard, governance |
| 4 | Integration testing + polish |
| 5 | Demo video + DoraHacks submission |

## 🔗 Links
- [Initia Docs](https://docs.initia.xyz)
- [DoraHacks Hackathon](https://dorahacks.io/hackathon/initiate)
- [Initia Testnet Explorer](https://scan.testnet.initia.xyz)

## 📜 License
MIT

---
*Green wheels, shared ownership, real impact.* 🌍⚡🚌
