// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

contract Listener {
    function onkill(
        uint _eventid,
        string memory _killer,
        string memory _target
    ) external virtual {}
    
    function ontransfer(
        uint _eventid,
        uint _amount,
        string memory _player
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
        emit Transfer(
            msg.value,
            player
        );
    }
    
    event OnTransfer(
        uint eventid,
        string player
    );
    
    /**
     * Trigger ontransfer when player transfers ingame EMRLD to your contract
     * Set player to "" to include any player
     **/
    function ontransfer(
      string memory player
    ) public returns (uint){
        uint eventid = lastid++;
        ids[eventid] = msg.sender;
        
        emit OnTransfer(
            eventid, 
            player
        );
        
        return eventid;
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
}
