// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.4;
 
contract SizovGame {
 
    struct Participant {
        address payable playerAddress;
        uint256 readyToPlay;
        uint256 choice;
        bytes32 move;
    }
 
 
    Participant participantFirst = Participant(payable(address(0x0)), 1, 0, 0x0);
    Participant participantSecond = Participant(payable(address(0x0)), 1, 0, 0x0);
 
    event PlyerAdded(address player);
    event PlayerAddSymbol(address player);
    event PlayerReveal(address player, uint256 choice);
    event PlayerPayed(address player, uint amount);
 
 
    uint public bettedValue = 0;
 
    modifier isAppliable() {
        require(
            (participantFirst.playerAddress == payable(address(0x0)) ||
             participantSecond.playerAddress == payable(address(0x0))) &&
                (participantFirst.readyToPlay == 1 ||
                 participantSecond.readyToPlay == 1) &&
                (participantFirst.move == 0x0 || participantSecond.move == 0x0) && 
                (participantFirst.choice == 0 || participantSecond.choice == 0)
                );
 
        _;
    }
 
     modifier bettedValueted() {
        require(msg.value > 0);
 
        _;
    }
 
    function addPlayer() public payable isAppliable bettedValueted returns (uint) {
        if (participantFirst.readyToPlay == 1) {
 
            if (participantSecond.readyToPlay == 1){
                bettedValue = msg.value;
            } else {
                require(bettedValue == msg.value, "invalid value");
            }
 
            participantFirst.playerAddress = payable(msg.sender);
            participantFirst.readyToPlay = 2;
 
            emit PlyerAdded(msg.sender);
            return 1;
        } else if (participantSecond.readyToPlay == 1) {
 
            if (participantFirst.readyToPlay == 1){
                bettedValue = msg.value;
            } else {
                require(bettedValue == msg.value, "invalid value");
            }
 
 
 
            participantSecond.playerAddress = payable(msg.sender);
            participantSecond.readyToPlay = 2;
 
            emit PlyerAdded(msg.sender);
            return 2;
        }
        return 0;
    }
 
    modifier isReadyToGo() {
        require((participantFirst.playerAddress != payable(address(0x0)) 
        && participantSecond.playerAddress != payable(address(0x0))) &&
                (participantFirst.choice == 0 && participantSecond.choice == 0) &&
                (participantFirst.move == 0x0 
                || participantSecond.move == 0x0) && 
                (participantFirst.readyToPlay == 2
                 || participantSecond.readyToPlay == 2));
        _;
    }
 
    modifier isPlyerAdded() {
        require (msg.sender == participantFirst.playerAddress || msg.sender == participantSecond.playerAddress);
 
        _;
    }
 
    function go(bytes32 move) public isReadyToGo isPlyerAdded returns (bool) {
        if (msg.sender == participantFirst.playerAddress && participantFirst.move == 0x0) {
            participantFirst.move = move;
            participantFirst.readyToPlay = 3;
        } else if (msg.sender == participantSecond.playerAddress && participantSecond.move == 0x0) {
            participantSecond.move = move;
            participantSecond.readyToPlay = 3;
        } else {
            return false;
        }
        emit PlayerAddSymbol(msg.sender);
        return true;
    }
 
    modifier readyToShow() {
        require((participantFirst.choice == 0 || participantSecond.choice == 0) &&
                (participantFirst.move != 0x0 && participantSecond.move != 0x0) && 
                (participantFirst.readyToPlay == 3 || participantSecond.readyToPlay == 3));
        _;
    }
 
    function show(uint256 choice, string calldata pad) public readyToShow isPlyerAdded returns (bool) {
        if (msg.sender == participantFirst.playerAddress) {
            require(sha256(abi.encodePacked(msg.sender, choice, pad)) == participantFirst.move, "exception");
 
 
            participantFirst.choice = choice;
            participantFirst.readyToPlay = 4;
 
            emit PlayerReveal(msg.sender, choice);
            return true;
        } else if (msg.sender == participantSecond.playerAddress){
            require(sha256(abi.encodePacked(msg.sender, choice, pad)) == participantSecond.move, "exception");
            participantSecond.choice = choice;
 
            participantSecond.readyToPlay = 4;
 
            emit PlayerReveal(msg.sender, choice);
            return true;
        }
        return false;
    }
 
 
    modifier readyToPay() {
        require((participantFirst.choice != 0 && participantSecond.choice != 0) &&
                (participantFirst.move != 0x0 && participantSecond.move != 0x0) &&
                (participantFirst.readyToPlay == 4 && participantSecond.readyToPlay == 4));
        _;
    }
 
 
     function findWinner() public readyToPay isPlyerAdded returns (uint) {
 
        if (participantFirst.choice == participantSecond.choice) {
            address payable firstMember = participantFirst.playerAddress;
            address payable secondMember = participantFirst.playerAddress;
            uint amount = bettedValue;
            endGame();
            firstMember.transfer(amount);
            secondMember.transfer(amount);
            emit PlayerPayed(firstMember, amount);
            emit PlayerPayed(secondMember, amount);
            return 0;
        } else if ((
            participantFirst.choice == 1 && participantSecond.choice == 3) ||
                   (participantFirst.choice == 2 && participantSecond.choice == 1)     ||
                   (participantFirst.choice == 3 && participantSecond.choice == 2)) {
            address payable winnerMember = participantFirst.playerAddress;
            uint amount = 2 * bettedValue;
            endGame();
 
            winnerMember.transfer(amount);
            emit PlayerPayed(winnerMember, amount);
            return 1;
        } else {
            address payable winnerMember = participantSecond.playerAddress;
 
            uint amount = 2 * bettedValue;
            endGame();
            winnerMember.transfer(amount);
            emit PlayerPayed(winnerMember, amount);
            return 2;
        }
    }
 
    function endGame() private {
        participantFirst = Participant(payable(address(0x0)), 1, 0, 0x0);
        participantSecond = Participant(payable(address(0x0)), 1, 0, 0x0);
 
        bettedValue = 0;
    }
 
}
