// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract Listener {
    function onkill(
        uint eventid,
        string memory _killer,
        string memory _target
    ) external virtual {}
}

contract Craftereum {
    address public server;
    
    uint public lastid = 0;
    
    mapping(uint => address) public ids;
    
    constructor(){
        server = msg.sender;
    }
    
    event Cancel(uint eventid);
    
    function cancel(uint eventid) public {
        require(msg.sender == ids[eventid]);
        emit Cancel(eventid);
        delete ids[eventid];
    }
    
    event Kill(
        uint eventid,
        string[] killers,
        string[] targets
    );
    
    function onkill(
        string[] memory killers, 
        string[] memory targets
    ) public returns (uint) {
        uint eventid = lastid++;
        ids[eventid] = msg.sender;
        emit Kill(eventid, killers, targets);
        return eventid;
    }
}