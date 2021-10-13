// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./libs/IterableMapping.sol";

/**
 * @notice GrayBlock Staking Contract
 * @author Adam Lee
 */
contract GrayblockStaking is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    /// @notice Event emitted only on construction. To be used by indexers
    event GrayblockStakingContractDeployed();

    event TradedTokenPut(
        address engeryDeveloper,
        uint256 amount
    );

    event Staked(
        address staker,
        uint256 amount
    );

    event UnStaked(
        address staker,
        uint256 amount
    );

    event AllocationUpdated();

    /// @notice Traded Token Instance
    IERC20 public tradedToken;
    
    /// @notice Project Token Instance
    IERC20 public projectToken;

    /// @notice Address of feeCollector who received the fee
    address public feeCollector;

    /// @notice Bps of fee which goes to fee collector
    uint256 public feeBps;

    /// @notice Staking tokens should be locked during locktime in staking pool
    uint256 public lockTime = 1 days;

    /// @dev Iterable Mapping for staking information
    IterableMapping.Map stakeInfos;

    /// @notice Total staked project token balance
    uint256 public totalStakedBalance;

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
    ) {
        tradedToken = _tradedToken;
        projectToken = _projectToken;
        feeCollector = _feeCollector;
        feeBps = 100;
        
        emit GrayblockStakingContractDeployed();
    }

    /**
     * @notice Energy developers put traded token to our staking pool
     * @param _amount Amount of traded token
     */
    function putTradedToken(uint256 _amount) external {
        require(
            tradedToken.balanceOf(msg.sender) >= _amount,
            "insufficient balance"
        );

        tradedToken.transferFrom(msg.sender, address(this), _amount);

        emit TradedTokenPut(msg.sender, _amount);
    }

    /**
     * @notice Users stake project token into our pool
     * @param _amount Amount of project token
     */
    function stake(uint256 _amount) external {
        require(
            projectToken.balanceOf(msg.sender) >= _amount,
            "insufficient balance"
        );

        uint256 _actualAmount = _amount.mul(uint256(10000).sub(feeBps)).div(10000);
        projectToken.transferFrom(msg.sender, feeCollector, _amount.sub(_actualAmount));
        projectToken.transferFrom(msg.sender, address(this), _actualAmount);

        if(stakeInfos.inserted[msg.sender]) {
            stakeInfos.values[msg.sender].amount = stakeInfos.values[msg.sender].amount.add(_actualAmount);
            stakeInfos.values[msg.sender].stakedTime = _getNow();
        } else {
            IterableMapping.StakeInfo memory stakeInfo = IterableMapping.StakeInfo({
                amount: _actualAmount,
                stakedTime: _getNow(),
                rewardAmount: 0
            });

            stakeInfos.add(msg.sender, stakeInfo);
        }

        totalStakedBalance = totalStakedBalance.add(_actualAmount);

        emit Staked(msg.sender, _actualAmount);
    }

    /**
     * @notice Users unstake project token from our pool after 24hrs
     * @param _amount Amount of project token
     */
    function unStake(uint256 _amount) external {
        IterableMapping.StakeInfo storage stakeInfo =  stakeInfos.values[msg.sender];
        
        require(
            stakeInfo.amount >= _amount,
            "insufficient balance"
        );
        require(
            _getNow() >= stakeInfo.stakedTime.add(lockTime),
            "can not unstake during lock time"
        );

        if(stakeInfo.amount == _amount) {
            stakeInfos.remove(msg.sender);
        } else {
            stakeInfo.amount = stakeInfo.amount.sub(_amount);
        }

        totalStakedBalance = totalStakedBalance.sub(_amount);

        projectToken.transfer(msg.sender, _amount);

        emit UnStaked(msg.sender, _amount);
    }

    /**
     * @notice Our Backend calls this function every 6hrs to calcuate the reward for every user
     */
    function updateAllocation(uint256 rewardAmount) external onlyOwner {
        uint256 tradedTokenBalance = tradedToken.balanceOf(address(this));

        require(
            tradedTokenBalance >= rewardAmount,
            "not enough reward"
        );

        for(uint256 i = 0; i < stakeInfos.size(); i++) {
            address key = stakeInfos.getKeyAtIndex(i);
            IterableMapping.StakeInfo storage stakeInfo =  stakeInfos.values[key];
            stakeInfo.rewardAmount = stakeInfo.rewardAmount.add(rewardAmount.mul(stakeInfo.amount).div(totalStakedBalance));
        }
        
        emit AllocationUpdated();
    }

    /**
     * @notice Users can claim reward
     */
    function claimReward() public {
        require(
            stakeInfos.inserted[msg.sender],
            "not staker"
        );
        require(
            stakeInfos.values[msg.sender].rewardAmount > 0,
            "no reward"
        );
        
        uint256 rewardAmount = stakeInfos.values[msg.sender].rewardAmount;
        stakeInfos.values[msg.sender].rewardAmount = 0;
        tradedToken.transfer(msg.sender, rewardAmount);
    }

    /**
     * @notice Get staking balance for each user
     */
    function getStake() external view returns(uint256) {
        return stakeInfos.values[msg.sender].amount;
    }

    /**
     * @notice Get staking time for each user
     */
    function getStakeTime() external view returns(uint256) {
        return stakeInfos.values[msg.sender].stakedTime;
    }

    /**
     * @notice Get if the user has staked or not
     */
    function getIfStake() external view returns(bool) {
        return stakeInfos.inserted[msg.sender];
    }

    /**
     * @notice Get reward amount for each user
     */
    function getReward() external view returns(uint256) {
        return stakeInfos.values[msg.sender].rewardAmount;
    }

    /**
     * @notice Owner can set the address of fee collector
     * @param _feeCollector addres of fee collector
     */
    function setFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;
    }

    /**
     * @notice Owner can set the bps of the fee
     * @param _feeBps Bps of the fee
     */
    function setFeeBps(uint256 _feeBps) external onlyOwner {
        feeBps = _feeBps;
    }

    /**
     * @notice Owner can set the lock time
     * @param _lockTime Lock time
     */
    function setLockTime(uint256 _lockTime) external onlyOwner {
        lockTime = _lockTime;
    }

    function _getNow() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}
