// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Token is Ownable, ERC20  {
    
    constructor() public ERC20("TBUSD", "BUSD") {
        _mint(_msgSender(), 10000000000000000000000000);
        // _setupDecimals(0);
    }

}
