// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DAO is ReentrancyGuard, AccessControl {

    //  Users of the DAO will be of two types - Contributors and Stakeholders. We need to declare two constants here, which are the keccak256 hash of the words themselves. 
    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 public constant STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");


    // The minimumVotingPeriod variable holds the number of days a proposal can be voted on in UNIX time.
    uint32 constant minimumVotingPeriod = 1 weeks;

    // numOfProposals is incremented every time a new charity proposal is added.
    uint256 numOfProposals;

//    The Mortgageproposal struct definition holds the necessary data that makes up each proposal object.
    struct MortgageProposal {
        uint256 id;
        uint256 amount;
        uint256 livePeriod;
        uint256 votesFor;
        uint256 votesAgainst;
        string description;
        bool votingPassed;
        bool paid;
        address payable Address;
        address proposer;
        address paidBy;
    }



    mapping(uint256 =>  MortgageProposal) private  mortgageProposal;
    mapping(address => uint256[]) private stakeholderVotes;
    mapping(address => uint256) private contributors;
    mapping(address => uint256) private stakeholders;

    event ContributionReceived(address indexed fromAddress, uint256 amount);
    event NewMorgageProposal(address indexed proposer, uint256 amount);
    event PaymentTransfered(
        address indexed stakeholder,
        address indexed charityAddress,
        uint256 amount
    );

    modifier onlyStakeholder(string memory message) {
        require(hasRole(STAKEHOLDER_ROLE, msg.sender), message);
        _;
    }

    modifier onlyContributor(string memory message) {
        require(hasRole(CONTRIBUTOR_ROLE, msg.sender), message);
        _;
    }

    function createProposal(
        string calldata description,
        address charityAddress,
        uint256 amount
    )
        external
        onlyStakeholder("Only stakeholders are allowed to create proposals")
    {
        uint256 proposalId = numOfProposals++;
        MortgageProposal storage proposal = mortgageProposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = payable(msg.sender);
        proposal.description = description;
        proposal.charityAddress = payable(charityAddress);
        proposal.amount = amount;
        proposal.livePeriod = block.timestamp + minimumVotingPeriod;

        emit NewMortgageProposal(msg.sender, amount);
    }

    function vote(uint256 proposalId, bool supportProposal)
        external
        onlyStakeholder("Only stakeholders are allowed to vote")
    {
        MortgageProposal storage MortgageProposal = mortgageProposals[proposalId];

        votable(MortgageProposal);

        if (supportProposal) MortgageProposal.votesFor++;
        else MortgageProposal.votesAgainst++;

        stakeholderVotes[msg.sender].push(MortgageProposal.id);
    }

    function votable(MortgageProposal storage MortgageProposal) private {
        if (
            MortgageProposal.votingPassed ||
            MortgageProposal.livePeriod <= block.timestamp
        ) {
            MortgageProposal.votingPassed = true;
            revert("Voting period has passed on this proposal");
        }

        uint256[] memory tempVotes = stakeholderVotes[msg.sender];
        for (uint256 votes = 0; votes < tempVotes.length; votes++) {
            if (MortgageProposal.id == tempVotes[votes])
                revert("This stakeholder already voted on this proposal");
        }
    }

    function payCharity(uint256 proposalId)
        external
        onlyStakeholder("Only stakeholders are allowed to make payments")
    {
        MortgageProposal storage MortgageProposal = MortgageProposals[proposalId];

        if (MortgageProposal.paid)
            revert("Payment has been made to this charity");

        if (MortgageProposal.votesFor <= MortgageProposal.votesAgainst)
            revert(
                "The proposal does not have the required amount of votes to pass"
            );

        MortgageProposal.paid = true;
        MortgageProposal.paidBy = msg.sender;

        emit PaymentTransfered(
            msg.sender,
            MortgageProposal.charityAddress,
            MortgageProposal.amount
        );

        return MortgageProposal.charityAddress.transfer(mortgageProposal.amount);
    }

    receive() external payable {
        emit ContributionReceived(msg.sender, msg.value);
    }

    function makeStakeholder(uint256 amount) external {
        address account = msg.sender;
        uint256 amountContributed = amount;
        if (!hasRole(STAKEHOLDER_ROLE, account)) {
            uint256 totalContributed =
                contributors[account] + amountContributed;
            if (totalContributed >= 5 ether) {
                stakeholders[account] = totalContributed;
                contributors[account] += amountContributed;
                _setupRole(STAKEHOLDER_ROLE, account);
                _setupRole(CONTRIBUTOR_ROLE, account);
            } else {
                contributors[account] += amountContributed;
                _setupRole(CONTRIBUTOR_ROLE, account);
            }
        } else {
            contributors[account] += amountContributed;
            stakeholders[account] += amountContributed;
        }
    }

    function getProposals()
        public
        view
        returns (mortgageProposal[] memory props)
    {
        props = new mortgageProposal[](numOfProposals);

        for (uint256 index = 0; index < numOfProposals; index++) {
            props[index] = mortgageProposals[index];
        }
    }

    function getProposal(uint256 proposalId)
        public
        view
        returns (mortgageProposal memory)
    {
        return mortgageProposals[proposalId];
    }

    function getStakeholderVotes()
        public
        view
        onlyStakeholder("User is not a stakeholder")
        returns (uint256[] memory)
    {
        return stakeholderVotes[msg.sender];
    }

    function getStakeholderBalance()
        public
        view
        onlyStakeholder("User is not a stakeholder")
        returns (uint256)
    {
        return stakeholders[msg.sender];
    }

    function isStakeholder() public view returns (bool) {
        return stakeholders[msg.sender] > 0;
    }

    function getContributorBalance()
        public
        view
        onlyContributor("User is not a contributor")
        returns (uint256)
    {
        return contributors[msg.sender];
    }

    function isContributor() public view returns (bool) {
        return contributors[msg.sender] > 0;
    }
}