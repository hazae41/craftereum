// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;

import "./Emeralds.sol";

abstract contract Listener {
    function onkill(
        uint _eventid,
        string memory _killer,
        string memory _target
    ) external virtual {}
}

contract Craftereum {
    Emeralds public emeralds;
    
    address payable public server;
    
    uint public lastid = 0;
    
    mapping(uint => address) public ids;
    
    constructor(){
        emeralds = new Emeralds(this);
        server = msg.sender;
    }
    
    /**
     * Tell the server to cancel an event
     **/
    event Cancel(uint eventid);
    
    /**
     * Cancel an event
     **/
    function cancel(uint eventid) external {
        require(msg.sender == ids[eventid]);
       _cancel(eventid);
    }
    
    /**
     * Internal cancel shortcut
     * Called by cancel() and event triggers
     **/
    function _cancel(uint eventid) internal {
        delete ids[eventid];
        emit Cancel(eventid);
    }
    
    /**
     * Tell the server to give emeralds to a player
     **/
    event Transfer(
        string player,
        uint amount
    );
    
    /**
     * Transfer blockchain EMRLD to a player
     **/
    function transfer(
        string memory player,
        uint amount
    ) external {
        require(emeralds.burn(msg.sender, amount));
        emit Transfer(player, amount);
    }
    
    /**
     * Transfer ingame EMRLD to the blockchain
     **/
    function _transfer(
        address account,
        uint amount
    ) external {
        require(msg.sender == server);
        require(emeralds.mint(account, amount));
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
    ) external returns (uint) {
        uint eventid = lastid++;
        ids[eventid] = msg.sender;
        
        emit OnKill(
            eventid, 
            killer,
            target
        );
        
        return eventid;
    }

    /**
     * Kill event trigger
     **/ 
    function _killed(
        uint eventid,
        string memory killer, 
        string memory target
    ) external {
        require(msg.sender == server);
        Listener listener = Listener(ids[eventid]);
        listener.onkill(eventid, killer, target);
        _cancel(eventid);
    }
}
