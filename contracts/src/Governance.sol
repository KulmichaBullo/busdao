// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BusDAOGovernance
 * @notice Token-weighted governance for BusDAO decisions.
 *         BUS holders vote on: vehicle purchases, route selection, payout frequency.
 */
contract BusDAOGovernance is Ownable {
    /// @notice BUS token contract
    address public busToken;

    /// @notice Treasury contract
    address public treasury;

    /// @notice Proposal counter
    uint256 public proposalCount;

    /// @notice Voting period in seconds (default 3 days)
    uint256 public votingPeriod;

    /// @notice Quorum threshold (minimum BUS tokens to vote, in wei)
    uint256 public quorumThreshold;

    struct Proposal {
        uint256 id;
        string description;
        string proposalType; // "PURCHASE_VEHICLE", "SELECT_ROUTE", "PAYOUT_FREQUENCY"
        uint256 amount; // For purchase proposals
        string details; // Route name, frequency, etc.
        uint256 forVotes;
        uint256 againstVotes;
        uint256 deadline;
        bool executed;
        address proposer;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    /// @notice Emitted when a proposal is created
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string proposalType, string description);

    /// @notice Emitted when someone votes
    event Voted(uint256 indexed proposalId, address indexed voter, bool support, uint256 weight);

    /// @notice Emitted when a proposal is executed
    event ProposalExecuted(uint256 indexed proposalId, bool passed);

    constructor(address _busToken, address _treasury) Ownable(msg.sender) {
        busToken = _busToken;
        treasury = _treasury;
        votingPeriod = 3 days;
        quorumThreshold = 1000 * 1e18; // 1000 BUS minimum quorum
    }

    /**
     * @notice Create a new proposal
     * @param description Human-readable description
     * @param proposalType Type of proposal (PURCHASE_VEHICLE, SELECT_ROUTE, PAYOUT_FREQUENCY)
     * @param amount For purchase proposals — the cost
     * @param details Route name, payout frequency, etc.
     */
    function createProposal(
        string calldata description,
        string calldata proposalType,
        uint256 amount,
        string calldata details
    ) external returns (uint256) {
        // Check proposer has BUS tokens
        (bool success, bytes memory data) = busToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", msg.sender)
        );
        require(success && data.length >= 32, "Failed to check balance");
        uint256 balance = abi.decode(data, (uint256));
        require(balance >= 1e18, "Need at least 1 BUS to propose");

        proposalCount++;
        uint256 proposalId = proposalCount;

        proposals[proposalId] = Proposal({
            id: proposalId,
            description: description,
            proposalType: proposalType,
            amount: amount,
            details: details,
            forVotes: 0,
            againstVotes: 0,
            deadline: block.timestamp + votingPeriod,
            executed: false,
            proposer: msg.sender
        });

        emit ProposalCreated(proposalId, msg.sender, proposalType, description);
        return proposalId;
    }

    /**
     * @notice Vote on a proposal
     * @param proposalId The proposal to vote on
     * @param support true = for, false = against
     */
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal doesn't exist");
        require(!proposal.executed, "Already executed");
        require(block.timestamp <= proposal.deadline, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        // Get voter's BUS balance
        (bool success, bytes memory data) = busToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", msg.sender)
        );
        require(success && data.length >= 32, "Failed to check balance");
        uint256 weight = abi.decode(data, (uint256));
        require(weight > 0, "No BUS tokens");

        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }

        emit Voted(proposalId, msg.sender, support, weight);
    }

    /**
     * @notice Execute a passed proposal
     * @param proposalId The proposal to execute
     */
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal doesn't exist");
        require(!proposal.executed, "Already executed");
        require(block.timestamp > proposal.deadline, "Voting not ended");

        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        require(totalVotes >= quorumThreshold, "Quorum not met");
        require(proposal.forVotes > proposal.againstVotes, "Proposal rejected");

        proposal.executed = true;

        emit ProposalExecuted(proposalId, true);
    }

    /**
     * @notice Get proposal results
     */
    function getProposalResult(uint256 proposalId) external view returns (
        uint256 forVotes,
        uint256 againstVotes,
        bool passed,
        bool executed
    ) {
        Proposal storage p = proposals[proposalId];
        return (p.forVotes, p.againstVotes, p.forVotes > p.againstVotes, p.executed);
    }

    /**
     * @notice Update quorum threshold
     */
    function setQuorum(uint256 _quorum) external onlyOwner {
        quorumThreshold = _quorum;
    }

    /**
     * @notice Update voting period
     */
    function setVotingPeriod(uint256 _period) external onlyOwner {
        require(_period >= 1 hours, "Min 1 hour");
        votingPeriod = _period;
    }
}
