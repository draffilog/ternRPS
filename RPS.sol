// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    
    address payable public player;
    address payable public bot;
    uint public playerMove;
    uint public botMove;
    uint public playerBet;
    uint public botBet;
    uint public winner;
    
    constructor() payable {
        bot = payable(address(this));
    }

    function play(uint _playerMove) public payable {
        require(msg.value > 0, "You must make a bet to play");
        require(_playerMove >= 1 && _playerMove <= 3, "Invalid move");
        player = payable(msg.sender);
        playerMove = _playerMove;
        playerBet = msg.value;
        botMove = generateBotMove();
        botBet = playerBet;
        winner = determineWinner();
        if(winner == 1) {
            player.transfer(address(this).balance);
        }
        else if(winner == 2) {
            bot.transfer(address(this).balance);
        }
        else {
            player.transfer(playerBet);
            bot.transfer(botBet);
        }
    }

    function generateBotMove() private view returns(uint) {
        uint seed = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, bot)));
        return seed % 3 + 1;
    }

    function determineWinner() private view returns(uint) {
        if(playerMove == botMove) {
            return 0;
        }
        else if((playerMove == 1 && botMove == 3) || (playerMove == 2 && botMove == 1) || (playerMove == 3 && botMove == 2)) {
            return 1;
        }
        else {
            return 2;
        }
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw() public {
        require(msg.sender == player || msg.sender == bot, "Only the player or bot can withdraw funds");
        uint amount = 0;
        if (msg.sender == player) {
            amount = playerBet;
            playerBet = 0;
        } else if (msg.sender == bot) {
            amount = botBet;
            botBet = 0;
        }
        if (amount > 0) {
            payable(msg.sender).transfer(amount);
        }
    }

    receive() external payable {
        // do something with the received Ether
    }
}
