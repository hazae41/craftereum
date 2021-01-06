// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

library Utils {
    function equals(
        string memory a, 
        string memory b
    ) internal pure returns (bool) {
        bytes32 ax = keccak256(abi.encodePacked(a));
        bytes32 bx = keccak256(abi.encodePacked(b));
        return ax == bx;
    }
}