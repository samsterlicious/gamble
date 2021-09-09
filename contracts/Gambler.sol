// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Gambler {
    address private owner;

    mapping(bytes32 => Bet) public bets;

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    function createBet(
        string calldata sport,
        string calldata ownerPick,
        string calldata otherPick,
        string calldata eventName,
        uint256 cutoffDate,
        uint256 settleDate,
        bytes32 key
    ) external payable onlyOwner {
        require(settleDate > cutoffDate);
        Bet memory bet = Bet(
            sport,
            address(0x0),
            ownerPick,
            otherPick,
            eventName,
            msg.value,
            cutoffDate,
            settleDate,
            false
        );
        bets[key] = bet;
    }

    function acceptBet(bytes32 key) external payable {
        Bet storage bet = bets[key];
        require(msg.value >= bet.amount);
        bet.competitor = msg.sender;
    }

    function resolveBet(bytes32 key, bool didIWin) external payable {
        // require(msg.sender == address(0x0));
        Bet memory bet = bets[key];
        require(block.timestamp >= bet.settleDate);
        if (didIWin) {
            payable(owner).transfer(bet.amount * 2);
        } else {
            payable(bet.competitor).transfer(bet.amount * 2);
        }
        delete bets[key];
    }

    struct Bet {
        string sport;
        address competitor;
        string ownerPick;
        string otherPick;
        string eventName;
        uint256 amount;
        uint256 cutoffDate;
        uint256 settleDate;
        bool didIWin;
    }
}
