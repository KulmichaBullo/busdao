# Deploy Guide

## Prerequisites
1. Weave CLI installed
2. Initia testnet tokens from faucet: https://app.testnet.initia.xyz/faucet

## Step 1: Deploy MiniEVM Rollup

```bash
weave init
# Fund gas station with INIT from faucet
weave rollup launch
# Select: VM = EVM, Chain ID = busdao-1, denom = uinit
```

## Step 2: Deploy Contracts

```bash
cd contracts

# Deploy MockStablecoin (for testnet)
forge create src/MockStablecoin.sol:MockStablecoin \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY>

# Deploy BUSToken
forge create src/BUSToken.sol:BUSToken \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY>

# Deploy BusDAOTreasury
forge create src/BusDAOTreasury.sol:BusDAOTreasury \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY> \
  --constructor-args <BUSToken_ADDR> <STABLECOIN_ADDR> 10000000000000000

# Deploy ProfitDistributor
forge create src/ProfitDistributor.sol:ProfitDistributor \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY> \
  --constructor-args <BUSToken_ADDR> <STABLECOIN_ADDR>

# Deploy Governance
forge create src/Governance.sol:Governance \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY> \
  --constructor-args <BUSToken_ADDR> <TREASURY_ADDR>

# Transfer BUS token ownership to Treasury
cast send <BUSToken_ADDR> "transferOwnership(address)" <TREASURY_ADDR> \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY>
```

## Or use the deploy script:

```bash
STABLECOIN=<MOCK_STABLECOIN_ADDR> forge script script/Deploy.s.sol \
  --rpc-url <YOUR_ROLLUP_RPC> \
  --private-key <YOUR_KEY> \
  --broadcast
```

## Network Info
- L1 Testnet: initiation-2
- Shared EVM Testnet: evm-1 (chain ID: 2124225178762456)
- JSON-RPC: https://jsonrpc-evm-1.anvil.asia-southeast.initia.xyz
- Explorer: https://scan.testnet.initia.xyz
- Faucet: https://app.testnet.initia.xyz/faucet
