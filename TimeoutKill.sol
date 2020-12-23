// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

import "./Utils.sol";
import "./Craftereum.sol";

/**
 * Contract that bets killer will kill target within the deadline
 * If so, the bettor wins the balance, else, the issuer wins the balance
 **/
contract TimeoutKill is Listener {
    Craftereum public craftereum;
    IEmeralds public emeralds;
    
    address payable public issuer;
    address payable public bettor; 
    
    string public killerPlayer;
    string public targetPlayer;
    
    uint public expirationTime;
    uint public eventid;
    
    constructor(
        Craftereum _craftereum,
        address payable _bettor,
        string memory _killerPlayer,
        string memory _targetPlayer,
        uint _expirationTime
    ){
        craftereum = _craftereum;
        emeralds = craftereum.emeralds();
        
        issuer = msg.sender;
        bettor = _bettor;
        
        killerPlayer = _killerPlayer;
        targetPlayer = _targetPlayer;
        expirationTime = _expirationTime;
        
        // Wait for a kill 
        eventid = craftereum.onkill(killerPlayer, targetPlayer);
    }
    
    function balance() external view returns (uint) {
        return emeralds.balance();
    }
    
    /**
     * Pay the bettor with blockchain EMRLD 
     **/
    function onkill(
        uint _eventid,
        string memory _killerPlayer,
        string memory _targetPlayer
    ) external override {
        require(msg.sender == address(craftereum));
        require(block.timestamp < expirationTime);
        
        require(_eventid == eventid);
        require(Utils.equals(_targetPlayer, targetPlayer));
        require(Utils.equals(_killerPlayer, killerPlayer));
        
        craftereum.cancel(eventid);
        
        uint amount = emeralds.balance();
        emeralds.transfer(bettor, amount);
    }
    
    /**
     * Refund the issuer
     **/
    function refund() external {
        require(msg.sender == issuer);
        require(block.timestamp > expirationTime);
        
        craftereum.cancel(eventid);
        
        uint amount = emeralds.balance();
        emeralds.transfer(issuer, amount);
    }
}
