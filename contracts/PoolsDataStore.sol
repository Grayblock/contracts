pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolsDataStore is Ownable {
    mapping(address => string) private dataStore;

    function setData(address _pool, string memory _value) external onlyOwner {
        dataStore[_pool] = _value;
    }

    function getData(address _pool)
        external
        view
        onlyOwner
        returns (string memory)
    {
        return dataStore[_pool];
    }
}
