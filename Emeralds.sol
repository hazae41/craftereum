// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.8.0;

import "./Craftereum.sol";

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/IERC20.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC20/ERC20.sol";

abstract contract IEmeralds is IERC20 {
    Craftereum public craftereum;

    function balance() external virtual view returns (uint);

    function mint(address account, uint amount) external virtual returns (bool);

    function burn(address account, uint amount) external virtual returns (bool);
}

contract Emeralds is ERC20("Emeralds", "EMRLD"), IEmeralds {
    
    constructor(Craftereum _craftereum) { 
        craftereum = _craftereum;
        _setupDecimals(0);
    }
    
    function balance() external override view returns (uint) {
      return balanceOf(msg.sender);
    }
    
    function mint(address account, uint amount) external override returns (bool) {
        require(msg.sender == address(craftereum));
        _mint(account, amount);
        return true;
    }
    
    function burn(address account, uint amount) external override returns (bool) {
        require(msg.sender == address(craftereum));
        _burn(account, amount);
        return true;
    }
}