pragma solidity ^0.8.0;

contract StakeMapping {
    struct StakeInfo {
        uint256 amount;
        uint256 stakedTime;
        uint256 rewardAmount;
    }

    struct Map {
        mapping(address => StakeInfo) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    mapping(address => Map) internal stakeMappings;
    address[] internal keys;

    function get(address key) internal view returns (StakeInfo memory) {
        return stakeMappings[msg.sender].values[key];
    }

    function getIndexOfKey(address key) internal view returns (int256) {
        if (!stakeMappings[msg.sender].inserted[key]) {
            return -1;
        }
        return int256(stakeMappings[msg.sender].indexOf[key]);
    }

    function getKeyAtIndex(uint256 index) internal view returns (address) {
        return keys[index];
    }

    function size() internal view returns (uint256) {
        return keys.length;
    }

    function add(address key, StakeInfo memory val) internal {
        if (stakeMappings[msg.sender].inserted[key]) {
            stakeMappings[msg.sender].values[key] = val;
        } else {
            stakeMappings[msg.sender].inserted[key] = true;
            stakeMappings[msg.sender].values[key] = val;
            stakeMappings[msg.sender].indexOf[key] = keys.length;
            keys.push(key);
        }
    }

    function remove(address key) internal {
        if (!stakeMappings[msg.sender].inserted[key]) {
            return;
        }

        delete stakeMappings[msg.sender].inserted[key];
        delete stakeMappings[msg.sender].values[key];

        uint256 index = stakeMappings[msg.sender].indexOf[key];
        uint256 lastIndex = keys.length - 1;
        address lastKey = keys[lastIndex];

        stakeMappings[msg.sender].indexOf[lastKey] = index;
        delete stakeMappings[msg.sender].indexOf[key];

        keys[index] = lastKey;
        keys.pop();
    }
}
