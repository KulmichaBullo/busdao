// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BUSToken.sol";
import "../src/BusDAOTreasury.sol";
import "../src/ProfitDistributor.sol";
import "../src/Governance.sol";

/**
 * @title DeployBusDAO
 * @notice Deployment script for all BusDAO contracts
 * 
 * Usage:
 *   forge script script/Deploy.s.sol --rpc-url <RPC> --private-key <KEY> --broadcast
 */
contract DeployBusDAO is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        
        // Stablecoin address (use MockStablecoin for testnet, real USDC for mainnet)
        address stablecoin = vm.envAddress("STABLECOIN");
        
        // Investment rate: 1 BUS = 0.01 stablecoin (100 BUS per 1 stablecoin)
        uint256 investmentRate = 0.01 ether;
        
        vm.startBroadcast(deployerKey);
        
        // 1. Deploy BUS Token
        BUSToken busToken = new BUSToken();
        console.log("BUSToken:", address(busToken));
        
        // 2. Deploy Treasury
        BusDAOTreasury treasury = new BusDAOTreasury(
            address(busToken),
            stablecoin,
            investmentRate
        );
        console.log("BusDAOTreasury:", address(treasury));
        
        // 3. Deploy Profit Distributor
        ProfitDistributor distributor = new ProfitDistributor(
            address(busToken),
            stablecoin
        );
        console.log("ProfitDistributor:", address(distributor));
        
        // 4. Deploy Governance
        Governance governance = new Governance(
            address(busToken),
            address(treasury)
        );
        console.log("Governance:", address(governance));
        
        // 5. Transfer BUS token ownership to treasury (so it can mint)
        busToken.transferOwnership(address(treasury));
        console.log("BUSToken ownership -> Treasury");
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Complete ===");
        console.log("BUSToken:         ", address(busToken));
        console.log("BusDAOTreasury:   ", address(treasury));
        console.log("ProfitDistributor:", address(distributor));
        console.log("Governance:       ", address(governance));
    }
}
