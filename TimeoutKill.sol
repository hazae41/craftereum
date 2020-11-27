// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "Utils.sol";
import "Craftereum.sol";

/**
 * Contract that bets killer will kill target within the deadline
 * If so, the bettor wins the balance, else, the owner wins the balance
 **/
contract TimeoutKill is Listener {
    Craftereum craftereum = Craftereum(0x0);
    
    address payable public issuer;
    address payable public bettor; 
    
    string[] public killers;
    string[] public targets;
    
    uint public expiration;
    uint public eventid;
    
    constructor(
        address payable _bettor,
        string memory _killer,
        string memory _target,
        uint _expiration
    ){
        issuer = msg.sender;
        bettor = _bettor;
        
        killers.push(_killer);
        targets.push(_target);
        expiration = _expiration;
        
        // Wait for a kill 
        eventid = craftereum.onkill(killers, targets);
    }
    
    function killer() public view returns(string memory) {
        return killers[0];
    }
    
    function target() public view returns(string memory) {
        return targets[0];
    }
    
    // Pay the bettor if the kill happened before contract expiration
    function onkill(
        uint _eventid,
        string memory _killer,
        string memory _target
    ) override public {
        require(msg.sender == craftereum.server());
        require(block.timestamp < expiration);
        require(_eventid == eventid);
        require(Utils.equals(_target, target()));
        require(Utils.equals(_killer, killer()));
        
        craftereum.cancel(eventid);
        bettor.transfer(address(this).balance);
    }
    
    // If the contract expired, the owner can be refunded
    function refund() public {
        require(msg.sender == issuer);
        require(block.timestamp > expiration);
        
        craftereum.cancel(eventid);
        issuer.transfer(address(this).balance);
    }
}