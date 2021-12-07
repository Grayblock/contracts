pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import './StakingGrayblock.sol';

contract StakingFactory is Ownable {
    address[] public stakingAddresses;
    address public feeCollector;
  

    event StakingDeployed(address _tradeToken, address _projectToken);
    event HarvestAll(address _staker);
    event FeeCollector(address feeCollector);

    constructor(address _feeCollector) {
      feeCollector = _feeCollector;
    }

    function createStakingContract(IERC20 _tradeToken, IERC20 _projectToken, string memory _name) external onlyOwner returns(address _staking) {
        bytes memory bytecode = abi.encodePacked(type(GrayblockStaking).creationCode, abi.encode(_tradeToken, _projectToken, feeCollector, address(this), _name));

        bytes32 salt = keccak256(abi.encodePacked(_tradeToken, _projectToken, feeCollector, address(this), _name));

        assembly {
            _staking := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        stakingAddresses.push(_staking);
        emit StakingDeployed(address(_tradeToken), address(_projectToken));
    }

    function harvestAll(address _staker) external {
       for (uint256 i = 0; i < stakingAddresses.length; i++) {
         address stakeAddress = stakingAddresses[i];
         if (GrayblockStaking(stakeAddress).canClaimReward(_staker)) {
           GrayblockStaking(stakeAddress).claimReward(_staker);
         }
       }

       emit HarvestAll(_staker);
    }

    function _setFeeCollector(address _newFeeCollector) external onlyOwner {
      feeCollector = _newFeeCollector;
      emit FeeCollector(_newFeeCollector);
    }
}