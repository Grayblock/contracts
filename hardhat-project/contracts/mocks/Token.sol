// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Token is Ownable, ERC20, ERC20Burnable  {

    uint8 private _decimals = 0 ;
    
    constructor() public ERC20("Token", "TKN") {
        _mint(_msgSender(), 10000000000);
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function faucet(uint256 _amount) external {
        _mint(_msgSender(), _amount );
    }
}
