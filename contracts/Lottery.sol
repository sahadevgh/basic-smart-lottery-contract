// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title A Lottery Contract
 * @notice This contract allows users to enter a lottery and win prizes
 */
contract Lottery {
    // Declare state variables
    address public manager; // stores the address of the contract manager
    address payable[] public currentPlayers; // Stores players for the current round
    address[] public allPlayers; // Stores all players across all rounds
    address payable public winner; // stores the address of the winner of each round.
    bool public isComplete; // shows the current status of a round.;

    // Events
    event WinnerPicked(address indexed winner);

    // Constructor
    constructor() {
        manager = msg.sender;
        isComplete = false;
    }

 // Restricted modifier
    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    // Enter the lottery
    function enter() public payable {
        require(msg.value >= 0.001 ether, "Minimum entry fee is 0.001 ether");
        require(!isComplete, "Lottery is complete");

        // Add player to current round and overall history
        currentPlayers.push(payable(msg.sender));
        allPlayers.push(msg.sender);
    }

    // Pick a winner
    function pickWinner() public onlyManager {
    require(currentPlayers.length > 0, "No players in the lottery");
    require(!isComplete, "Lottery is complete");

    uint randomIndex = randomNumber() % currentPlayers.length;
    winner = currentPlayers[randomIndex];
    isComplete = true;
    emit WinnerPicked(winner);

    // Reset the currentPlayers array by truncating its length
    delete currentPlayers;
    }


    // Claim prize
    function claimPrize() public {
        require(msg.sender == winner, "You are not the winner");
        require(isComplete, "Lottery is not complete");
        winner.transfer(address(this).balance);

        // Reset the lottery state
        isComplete = false;
    }

    // Generate a random number
    function randomNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, currentPlayers.length)));
    }
   

    // Get all players
    function getAllPlayers() public view returns (address[] memory) {
        return allPlayers;
    }

    // Get current players
    function getCurrentPlayers() public view returns (address payable[] memory) {
        return currentPlayers;
    }
}

