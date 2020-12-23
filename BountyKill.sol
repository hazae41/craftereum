// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

import "./Utils.sol";
import "./Craftereum.sol";

/**
 * Contract that gives the balance to the first player who kills target within the deadline
 * If the contract is expired, the issuer can be refunded
 **/
contract BountyKill is Listener {
    Craftereum public craftereum;
    IEmeralds public emeralds;
    
    address payable public issuer;
    
    string public targetPlayer;
    
    uint public expirationTime;
    uint public eventid;
    
    constructor(
        Craftereum _craftereum,
        string memory _targetPlayer,
        uint _expirationTime
    ){
        craftereum = _craftereum;
        emeralds = craftereum.emeralds();
        
        issuer = msg.sender;

        targetPlayer = _targetPlayer;
        expirationTime = _expirationTime;
        
        // Wait for a kill from any player to target
        eventid = craftereum.onkill("", targetPlayer);
    }
    
    function balance() external view returns (uint) {
        return emeralds.balance();
    }
    
    /**
     * Pay the killer with ingame EMRLD
     **/
    function onkill(
        uint _eventid,
        string memory _killer,
        string memory _target
    ) external override {
        require(msg.sender == address(craftereum));
        require(block.timestamp < expirationTime);
        
        require(_eventid == eventid);
        require(Utils.equals(_target, targetPlayer));
        
        craftereum.cancel(eventid);
        
        uint amount = emeralds.balance();
        craftereum.transfer(_killer, amount);
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
