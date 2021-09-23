// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract Token is Ownable, ERC20, ERC20Burnable  {
    
    constructor() public ERC20("Token", "TKN") {
    }

    function faucet(uint256 _amount) external {
        _mint(_msgSender(), _amount );
    }
}
