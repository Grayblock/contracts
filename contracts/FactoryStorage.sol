pragma solidity ^0.8.0;

import "./Token.sol";

contract FactoryStorage {
    Token public tradeToken;

    struct Pool {
        address projectToken;
        string name;
    }

    mapping(address => Pool) public poolsData;
    event NewPool(address addr);
}
