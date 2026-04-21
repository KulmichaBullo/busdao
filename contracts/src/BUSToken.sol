// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BUSToken
 * @notice Fractional ownership token for BusDAO fleet.
 *         BUS tokens represent proportional ownership of the matatu/bus fleet.
 *         Holding BUS = your % share of fare revenue.
 */
contract BUSToken is ERC20, ERC20Burnable, Ownable {
    /// @notice Total number of vehicles in the fleet
    uint256 public totalVehicles;

    /// @notice Vehicle registry: vehicleId => isActive
    mapping(uint256 => bool) public vehicleExists;

    /// @notice Emitted when a new vehicle is added to the fleet
    event VehicleAdded(uint256 indexed vehicleId, string route, uint256 tokensMinted);

    constructor() ERC20("BusDAO Token", "BUS") Ownable(msg.sender) {}

    /**
     * @notice Mint BUS tokens when an investor deposits funds
     * @param to Recipient address
     * @param amount Amount of BUS tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice Record a new vehicle in the fleet and mint tokens to treasury
     * @param route The route the vehicle will operate on (e.g., "Nairobi-CBD to Westlands")
     * @param tokensToMint Amount of BUS tokens representing this vehicle
     */
    function addVehicle(string calldata route, uint256 tokensToMint) external onlyOwner {
        totalVehicles++;
        uint256 vehicleId = totalVehicles;
        vehicleExists[vehicleId] = true;
        _mint(msg.sender, tokensToMint);
        emit VehicleAdded(vehicleId, route, tokensToMint);
    }
}
