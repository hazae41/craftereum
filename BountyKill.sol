// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

import "./Utils.sol";
import "./Craftereum.sol";

/**
 * Contract that gives the balance to the first player who kills target within the deadline
 * If the contract is expired, the issuer can be refunded
 **/
contract BountyKill is Listener {
    Craftereum craftereum = Craftereum(0x0);
    
    address payable public issuer;
    
    string public target;
    
    uint public expiration;
    uint public eventid;
    
    constructor(
        string memory _target,
        uint _expiration
    ){
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
    ) override public {
        require(msg.sender == address(craftereum));
        require(block.timestamp < expiration);
        
        require(_eventid == eventid);
        require(Utils.equals(_target, target));
        
        craftereum.cancel(eventid);
        craftereum.transfer{
            value: address(this).balance
        }(_killer);
    }
    
    /**
     * Refund the issuer
     **/
    function refund() public {
        require(msg.sender == issuer);
        require(block.timestamp > expiration);
        
        craftereum.cancel(eventid);
        issuer.transfer(address(this).balance);
    }
}
