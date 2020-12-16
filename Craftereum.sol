// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

contract Listener {
    function onkill(
        uint _eventid,
        string memory _killer,
        string memory _target
    ) external virtual {}
}

contract Craftereum {
    address payable public server;
    
    uint public lastid = 0;
    
    mapping(uint => address) public ids;
    
    constructor(){
        server = msg.sender;
    }
    
    event Cancel(uint eventid);
    
    function cancel(uint eventid) public {
        require(msg.sender == ids[eventid]);
        emit Cancel(eventid);
    }
    
    function _cancelled(uint eventid) public {
        require(msg.sender == server);
        delete ids[eventid];
    }
    
    event Transfer(
        uint amount,
        string player
    );
    
    /**
     * Transfer msg.value amount of blockchain EMRLD to the given player
     **/
    function transfer(
        string memory player
    ) public payable {
        server.transfer(msg.value);
        
        emit Transfer(
            msg.value,
            player
        );
    }
    
    event OnKill(
        uint eventid,
        string killer,
        string target
    );
    
    /**
     * Trigger onkill when killer kills target
     * Set killer to "" to include any player
     * Set target to "" to include any player
     **/
    function onkill(
        string memory killer, 
        string memory target
    ) public returns (uint) {
        uint eventid = lastid++;
        ids[eventid] = msg.sender;
        
        emit OnKill(
            eventid, 
            killer,
            target
        );
        
        return eventid;
    }

    function _killed(
        uint eventid,
        string memory killer, 
        string memory target
    ) public {
        require(msg.sender == server);
        Listener listener = Listener(ids[eventid]);
        listener.onkill(eventid, killer, target);
        emit Cancel(eventid);
    }
}
