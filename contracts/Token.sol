

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

 import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract Token is ERC20PresetMinterPauser {
    address owner;
    constructor() ERC20PresetMinterPauser("Project1","GVE"){
        owner=msg.sender;
        uint256 initialSupply = 900000 * 10 ** decimals();
        
        _mint(_msgSender(), initialSupply);
    }

}