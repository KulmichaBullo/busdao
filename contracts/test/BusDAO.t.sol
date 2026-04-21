// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BUSToken.sol";
import "../src/BusDAOTreasury.sol";
import "../src/ProfitDistributor.sol";
import {BusDAOGovernance} from "../src/Governance.sol";
import "../src/MockStablecoin.sol";

contract BusDAOTest is Test {
    BUSToken busToken;
    MockStablecoin stablecoin;
    BusDAOTreasury treasury;
    ProfitDistributor distributor;
BusDAOGovernance gov;

    address owner = makeAddr("owner");
    address investor1 = makeAddr("investor1");
    address investor2 = makeAddr("investor2");
    address operator = makeAddr("operator");

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy contracts
        busToken = new BUSToken();
        stablecoin = new MockStablecoin();
        
        // Investment rate: 1 BUS = 0.01 USDC (1e16 wei)
        treasury = new BusDAOTreasury(address(busToken), address(stablecoin), 0.01 ether);
        distributor = new ProfitDistributor(address(busToken), address(stablecoin));
        gov = new BusDAOGovernance(address(busToken), address(treasury));
        
        // Transfer ownership of BUS token to treasury so it can mint
        busToken.transferOwnership(address(treasury));
        
        // Fund investors with stablecoin
        stablecoin.transfer(investor1, 1000 ether);
        stablecoin.transfer(investor2, 1000 ether);
        
        vm.stopPrank();
    }

    // ===== BUSToken Tests =====
    function test_tokenMetadata() public view {
        assertEq(busToken.name(), "BusDAO Token");
        assertEq(busToken.symbol(), "BUS");
        assertEq(busToken.totalVehicles(), 0);
    }

    // ===== Investment Flow =====
    function test_invest() public {
        vm.startPrank(investor1);
        stablecoin.approve(address(treasury), 100 ether);
        treasury.invest(100 ether);
        
        // 100 USDC at rate 0.01 = 10,000 BUS
        assertEq(busToken.balanceOf(investor1), 10000 ether);
        assertEq(treasury.totalRaised(), 100 ether);
        vm.stopPrank();
    }

    function test_invest_zeroFails() public {
        vm.startPrank(investor1);
        stablecoin.approve(address(treasury), 0);
        vm.expectRevert("Amount must be > 0");
        treasury.invest(0);
        vm.stopPrank();
    }

    // ===== Revenue Distribution =====
    function test_revenueDistribution() public {
        // Two investors invest
        vm.startPrank(investor1);
        stablecoin.approve(address(treasury), 100 ether);
        treasury.invest(100 ether);
        vm.stopPrank();
        
        vm.startPrank(investor2);
        stablecoin.approve(address(treasury), 100 ether);
        treasury.invest(100 ether);
        vm.stopPrank();
        
        // Fund operator with stablecoin
        vm.prank(owner);
        stablecoin.transfer(operator, 50 ether);
        
        // Set operator
        vm.prank(owner);
        distributor.setOperator(operator);
        
        // Operator deposits revenue
        vm.startPrank(operator);
        stablecoin.approve(address(distributor), 50 ether);
        distributor.depositRevenue(50 ether);
        vm.stopPrank();
        
        // Investor1 should be able to claim 25 ether (50% of 50)
        uint256 claimable = distributor.getClaimable(investor1, 1);
        assertEq(claimable, 25 ether);
    }

    // ===== Governance Tests =====
    function test_createProposal() public {
        // Invest first so investor has BUS tokens
        vm.startPrank(investor1);
        stablecoin.approve(address(treasury), 100 ether);
        treasury.invest(100 ether);
        
        uint256 proposalId = gov.createProposal(
            "Buy electric matatu for Route 23",
            "PURCHASE_VEHICLE",
            2000 ether,
            "Nairobi CBD to Westlands"
        );
        
        assertEq(proposalId, 1);
        vm.stopPrank();
    }

    function test_voteOnProposal() public {
        // Invest
        vm.startPrank(investor1);
        stablecoin.approve(address(treasury), 100 ether);
        treasury.invest(100 ether);
        
        // Create proposal
        uint256 proposalId = gov.createProposal(
            "Buy electric matatu",
            "PURCHASE_VEHICLE",
            2000 ether,
            "Route 23"
        );
        
        // Vote
        gov.vote(proposalId, true);
        
        // Check results after voting period
        vm.warp(block.timestamp + 4 days);
        
        (uint256 forVotes,,,) = gov.getProposalResult(proposalId);
        assertGt(forVotes, 0);
        vm.stopPrank();
    }

    // ===== Full Flow Integration Test =====
    function test_fullFlow() public {
        // 1. Two investors invest
        vm.startPrank(investor1);
        stablecoin.approve(address(treasury), 500 ether);
        treasury.invest(500 ether);
        vm.stopPrank();
        
        vm.startPrank(investor2);
        stablecoin.approve(address(treasury), 500 ether);
        treasury.invest(500 ether);
        vm.stopPrank();
        
        // Verify both have BUS tokens
        assertGt(busToken.balanceOf(investor1), 0);
        assertGt(busToken.balanceOf(investor2), 0);
        
        // 2. Create proposal to buy vehicle
        vm.startPrank(investor1);
        uint256 proposalId = gov.createProposal(
            "Buy electric matatu for Nairobi CBD route",
            "PURCHASE_VEHICLE",
            2000 ether,
            "Nairobi CBD to Westlands"
        );
        
        // 3. Both vote for
        gov.vote(proposalId, true);
        vm.stopPrank();
        
        vm.startPrank(investor2);
        gov.vote(proposalId, true);
        vm.stopPrank();
        
        // 4. Fast forward past voting period
        vm.warp(block.timestamp + 4 days);
        
        // 5. Execute proposal
        gov.executeProposal(proposalId);
        
        // Verify execution
        (,, bool passed, bool executed) = gov.getProposalResult(proposalId);
        assertTrue(passed);
        assertTrue(executed);
    }
}
