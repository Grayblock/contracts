pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Factory {
    IERC20 public tradeToken;

    struct Pool {
        address projectToken;
        string name;
    }

    mapping(address => Pool) public poolsData;
    event NewPool(address addr);

    function getPools() public view virtual returns (address[] memory);
}
