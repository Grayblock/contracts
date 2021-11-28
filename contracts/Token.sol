// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Token is Ownable, ERC20  {
    
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(_msgSender(), 10000000000000000000000000);
    }

    function mint(address _account, uint256 _amount) external onlyOwner{
      _mint(_account, _amount);
    }
}