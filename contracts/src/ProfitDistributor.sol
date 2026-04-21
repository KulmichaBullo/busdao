// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ProfitDistributor
 * @notice Receives fare revenue from matatu operations and distributes
 *         profits proportionally to BUS token holders.
 *         Operator deposits revenue → auto-splits to holders.
 */
contract ProfitDistributor is Ownable {
    /// @notice BUS token contract
    address public busToken;

    /// @notice Stablecoin for revenue distribution
    address public stablecoin;

    /// @notice Address authorized to deposit revenue (operator/SACCO)
    address public operator;

    /// @notice Total revenue deposited to date
    uint256 public totalRevenue;

    /// @notice Total distributed to holders
    uint256 public totalDistributed;

    /// @notice Per-round distribution tracking
    uint256 public distributionRound;
    
    /// @notice Revenue per round
    mapping(uint256 => uint256) public revenuePerRound;

    /// @notice Emitted when revenue is deposited
    event RevenueDeposited(address indexed operator, uint256 amount, uint256 round);

    /// @notice Emitted when profits are distributed
    event ProfitsDistributed(uint256 round, uint256 totalAmount, uint256 totalSupply);

    /// @notice Operator changed
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);

    constructor(address _busToken, address _stablecoin) Ownable(msg.sender) {
        busToken = _busToken;
        stablecoin = _stablecoin;
        operator = msg.sender;
    }

    /**
     * @notice Deposit revenue from matatu operations (operator only)
     * @param amount Amount of stablecoin revenue collected
     */
    function depositRevenue(uint256 amount) external {
        require(msg.sender == operator || msg.sender == owner(), "Not authorized");
        require(amount > 0, "Amount must be > 0");

        // Transfer stablecoin from operator
        (bool success,) = stablecoin.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this), amount)
        );
        require(success, "Transfer failed");

        distributionRound++;
        totalRevenue += amount;
        revenuePerRound[distributionRound] = amount;

        // Get total BUS supply
        (bool supplySuccess, bytes memory supplyData) = busToken.staticcall(
            abi.encodeWithSignature("totalSupply()")
        );
        require(supplySuccess && supplyData.length >= 32, "Failed to get supply");
        uint256 totalSupply = abi.decode(supplyData, (uint256));
        require(totalSupply > 0, "No BUS tokens exist");

        emit RevenueDeposited(operator, amount, distributionRound);
        emit ProfitsDistributed(distributionRound, amount, totalSupply);
    }

    /**
     * @notice Claim profits for a specific round
     * @param round The distribution round to claim from
     */
    function claimProfit(uint256 round) external {
        require(round <= distributionRound, "Invalid round");
        
        // Get user's BUS balance
        (bool balSuccess, bytes memory balData) = busToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", msg.sender)
        );
        require(balSuccess && balData.length >= 32, "Failed to get balance");
        uint256 userBalance = abi.decode(balData, (uint256));
        require(userBalance > 0, "No BUS tokens");

        // Get total supply
        (bool supplySuccess, bytes memory supplyData) = busToken.staticcall(
            abi.encodeWithSignature("totalSupply()")
        );
        require(supplySuccess && supplyData.length >= 32, "Failed to get supply");
        uint256 totalSupply = abi.decode(supplyData, (uint256));

        // Calculate share: (userBalance / totalSupply) * revenue
        uint256 revenue = revenuePerRound[round];
        uint256 share = (revenue * userBalance) / totalSupply;
        require(share > 0, "Nothing to claim");

        totalDistributed += share;

        (bool success,) = stablecoin.call(
            abi.encodeWithSignature("transfer(address,uint256)", msg.sender, share)
        );
        require(success, "Transfer failed");
    }

    /**
     * @notice Get claimable amount for a user in a specific round
     * @param user The user address
     * @param round The distribution round
     */
    function getClaimable(address user, uint256 round) external view returns (uint256) {
        if (round > distributionRound) return 0;
        
        (bool balSuccess, bytes memory balData) = busToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", user)
        );
        if (!balSuccess || balData.length < 32) return 0;
        uint256 userBalance = abi.decode(balData, (uint256));

        (bool supplySuccess, bytes memory supplyData) = busToken.staticcall(
            abi.encodeWithSignature("totalSupply()")
        );
        if (!supplySuccess || supplyData.length < 32) return 0;
        uint256 totalSupply = abi.decode(supplyData, (uint256));
        if (totalSupply == 0) return 0;

        return (revenuePerRound[round] * userBalance) / totalSupply;
    }

    /**
     * @notice Change operator address
     */
    function setOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Zero address");
        emit OperatorChanged(operator, _operator);
        operator = _operator;
    }
}
