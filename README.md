# 🚌 BusDAO

**Fractional ownership of African matatus/buses on Initia blockchain.**

## The Problem
- Electric buses/matatus in Kenya cost $15K-$250K
- Only large institutions can afford fleet ownership
- Current SACCO model is opaque — investors can't verify earnings
- Small investors and diaspora have no way to participate

## The Solution
BusDAO lets anyone invest in matatu/buses fractionally through tokenized ownership on Initia blockchain. Community-owned public transport with transparent revenue distribution.

## How It Works
1. **Invest** — Buy BUS tokens with stablecoins
2. **Acquire** — DAO votes to purchase a matatu/bus
3. **Route** — DAO votes which route, vehicle joins SACCO
4. **Operate** — Normal operations (driver + conductor, cash/M-Pesa fares)
5. **Earn** — Revenue distributed to token holders weekly/monthly

## Architecture (Initia MiniEVM)
- **BUSToken (ERC20)** — Fractional ownership token
- **BusDAOTreasury** — Holds funds, manages purchases
- **ProfitDistributor** — Receives revenue, splits to holders
- **Governance** — Token-weighted voting on proposals

## Tech Stack
- **Blockchain:** Initia (MiniEVM rollup on testnet)
- **Smart Contracts:** Solidity + Foundry
- **Frontend:** React + ethers.js
- **Network:** Initia testnet (initiation-2)

## Project Structure
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

## Timeline (Hackathon — 5 Days)
| Day | Deliverable |
|-----|-------------|
| 1 | Deploy MiniEVM rollup on Initia testnet |
| 2 | Smart contracts deployed |
| 3 | Frontend: invest, dashboard, governance |
| 4 | Integration testing + polish |
| 5 | Demo video + DoraHacks submission |

## Links
- [Initia Docs](https://docs.initia.xyz)
- [DoraHacks Hackathon](https://dorahacks.io/hackathon/initiate)
- [Initia Testnet Explorer](https://scan.testnet.initia.xyz)

## License
MIT
