// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BusDAOTreasury
 * @notice Manages DAO funds — receives investments, pays for vehicle purchases.
 *         Acts as the central treasury for the BusDAO.
 */
contract BusDAOTreasury is Ownable {
    /// @notice BUS token contract
    address public busToken;

    /// @notice Stablecoin accepted for investment (USDC/USDT on Initia)
    address public stablecoin;

    /// @notice Total funds raised from investors
    uint256 public totalRaised;

    /// @notice Total spent on vehicle purchases
    uint256 public totalSpent;

    /// @notice Investment rate: 1 BUS token per X stablecoin (in smallest unit)
    uint256 public investmentRate;

    /// @notice Emitted when someone invests
    event Invested(address indexed investor, uint256 stablecoinAmount, uint256 busTokensMinted);

    /// @notice Emitted when a vehicle is purchased
    event VehiclePurchased(uint256 indexed vehicleId, uint256 cost, string route);

    /// @notice Emitted when funds are withdrawn (emergency)
    event FundsWithdrawn(address indexed to, uint256 amount);

    constructor(address _busToken, address _stablecoin, uint256 _investmentRate) Ownable(msg.sender) {
        busToken = _busToken;
        stablecoin = _stablecoin;
        investmentRate = _investmentRate;
    }

    /**
     * @notice Invest stablecoins and receive BUS tokens
     * @param amount Amount of stablecoin to invest
     */
    function invest(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        
        // Transfer stablecoin from investor
        (bool success,) = stablecoin.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), amount)
        );
        require(success, "Transfer failed");

        // Calculate BUS tokens to mint
        uint256 busTokens = (amount * 1e18) / investmentRate;
        
        totalRaised += amount;

        // Mint BUS tokens to investor (via BUS token contract)
        (bool mintSuccess,) = busToken.call(
            abi.encodeWithSignature("mint(address,uint256)", msg.sender, busTokens)
        );
        require(mintSuccess, "Mint failed");

        emit Invested(msg.sender, amount, busTokens);
    }

    /**
     * @notice Purchase a vehicle for the fleet
     * @param vehicleId The vehicle ID in the BUS token registry
     * @param cost Amount of stablecoin to pay
     * @param route The route the vehicle will operate on
     */
    function purchaseVehicle(uint256 vehicleId, uint256 cost, string calldata route) external onlyOwner {
        require(cost <= getBalance(), "Insufficient treasury funds");
        totalSpent += cost;
        emit VehiclePurchased(vehicleId, cost, route);
    }

    /**
     * @notice Get available treasury balance (stablecoin)
     */
    function getBalance() public view returns (uint256) {
        (bool success, bytes memory data) = stablecoin.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        if (success && data.length >= 32) {
            return abi.decode(data, (uint256));
        }
        return 0;
    }

    /**
     * @notice Emergency withdrawal (governance-controlled in production)
     */
    function withdraw(address to, uint256 amount) external onlyOwner {
        (bool success,) = stablecoin.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        require(success, "Withdraw failed");
        emit FundsWithdrawn(to, amount);
    }

    /**
     * @notice Update investment rate
     */
    function setInvestmentRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0, "Rate must be > 0");
        investmentRate = _newRate;
    }
}
