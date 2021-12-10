pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FactoryStorage {
    IERC20 public tradeToken;

    struct Pool {
        address projectToken;
        string name;
    }

    mapping(address => Pool) public poolsData;
    event NewPool(address addr);
}
