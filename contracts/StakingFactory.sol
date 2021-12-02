pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './StakingGrayblock.sol';

contract StakingFactory is Ownable {
    address[] public stakingAddresses;
  

    event StakingDeployed(address _tradeToken, address _projectToken, address _feeCollector);
    event HarvestAll(address _staker);

    function createStakingContract(IERC20 _tradeToken, IERC20 _projectToken, address _feeCollector, string memory _name) external onlyOwner returns(address _staking) {
        bytes memory bytecode = abi.encodePacked(type(GrayblockStaking).creationCode, abi.encode(_tradeToken, _projectToken, _feeCollector, address(this), _name));

        bytes32 salt = keccak256(abi.encodePacked(_tradeToken, _projectToken, _feeCollector, address(this), _name));

        assembly {
            _staking := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        stakingAddresses.push(_staking);
        emit StakingDeployed(address(_tradeToken), address(_projectToken), _feeCollector);
    }

    function harvestAll(address _staker) external onlyOwner {
       for (uint256 i = 0; i < stakingAddresses.length; i++) {
         address stakeAddress = stakingAddresses[i];
         if (GrayblockStaking(stakeAddress).canClaimReward(_staker)) {
           GrayblockStaking(stakeAddress).claimReward(_staker);
         }
       }

       emit HarvestAll(_staker);
    }
}