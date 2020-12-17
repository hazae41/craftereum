// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;

import "./Craftereum.sol";

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/ERC20.sol";

contract Emeralds is ERC20("Emeralds", "EMRLD") {
    Craftereum public craftereum;
    
    constructor(Craftereum _craftereum) { 
        craftereum = _craftereum;
        _setupDecimals(0);
    }
    
    function balance() external view returns (uint) {
      return balanceOf(msg.sender);
    }
    
    function mint(address account, uint amount) external returns (bool) {
        require(msg.sender == address(craftereum));
        _mint(account, amount);
        return true;
    }
    
    function burn(address account, uint amount) external returns (bool) {
        require(msg.sender == address(craftereum));
        _burn(account, amount);
        return true;
    }
}