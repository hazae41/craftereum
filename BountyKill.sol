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
    
    string public target;
    
    uint public expiration;
    uint public eventid;
    
    constructor(
        Craftereum _craftereum,
        string memory _target,
        uint _expiration
    ){
        craftereum = _craftereum;
        emeralds = craftereum.emeralds();
        
        issuer = msg.sender;

        target = _target;
        expiration = _expiration;
        
        // Wait for a kill from any player to target
        eventid = craftereum.onkill("", target);
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
        require(block.timestamp * 1000 < expiration);
        
        require(_eventid == eventid);
        require(Utils.equals(_target, target));
        
        uint amount = emeralds.balance();
        craftereum.transfer(_killer, amount);
    }
    
    /**
     * Refund the issuer
     **/
    function refund() external {
        require(msg.sender == issuer);
        require(block.timestamp * 1000 > expiration);
        
        uint amount = emeralds.balance();
        emeralds.transfer(issuer, amount);
    }
}
