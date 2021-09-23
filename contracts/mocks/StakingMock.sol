// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../Staking.sol";

/**
 * @notice GrayBlock Staking Contract
 * @author Adam Lee
 */
contract GrayblockStakingMock is GrayblockStaking {

    uint256 public fakeBlockTimeStamp = 100;
    
    /**
     * @notice Constructor
     * @param _tradedToken Traded Token Instance
     * @param _projectToken Project Token Instance
     * @param _feeCollector Address of feeCollector
     */
    constructor(
        IERC20 _tradedToken,
        IERC20 _projectToken,
        address _feeCollector
    ) GrayblockStaking(_tradedToken, _projectToken, _feeCollector) {
    }

    function setBlockTimeStamp(uint256 _now) external {
        fakeBlockTimeStamp = _now;
    }

    function _getNow() internal override view returns (uint256) {
        return fakeBlockTimeStamp;
    }
}
