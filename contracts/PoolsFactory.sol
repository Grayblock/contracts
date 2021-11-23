pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "./Pools.sol";

contract PoolsFactory is Ownable {
  ERC20 public tradeToken;
  address[] public poolsAddresses;
  address private admin;

  uint256 constant SALT = 0xff;

  event Deployed(address addr, uint256 salt);
  event NewPool(address addr);

  struct Pool {
    address projectToken;
    string name;
  }

  mapping(address => Pool) public poolsData;

  constructor(ERC20 _tradeToken, address _admin) {
    tradeToken = _tradeToken;
    admin = _admin;
  }

  function getTokenBytecode(
    string memory _name,
    string memory _symbol
  ) public pure returns (bytes memory) {
    bytes memory bytecode = type(ERC20).creationCode;

    return abi.encodePacked(bytecode, abi.encode(_name, _symbol));
  }

  function getPoolsBytecode(
    ERC20 _projectToken
  ) public view returns (bytes memory) {
    bytes memory bytecode = type(Pools).creationCode;

    return abi.encodePacked(bytecode, abi.encode(_projectToken, tradeToken, admin));
  }

  function getAddress(bytes memory bytecode)
    public
    view
    returns (address)
  {
    bytes32 hash = keccak256(
      abi.encodePacked(bytes1(0xff), address(this), SALT, keccak256(bytecode))
    );

    // NOTE: cast last 20 bytes of hash to address
    return address(uint160(uint256(hash)));
  }

  function deploy(bytes memory bytecode) internal {
    address addr;

    assembly {
      addr := create2(0, add(bytecode, 0x20), mload(bytecode), SALT)

      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }


    emit Deployed(addr, SALT);
  }

  function DeployPool(string memory _poolName, string memory _name, string memory _symbol) external onlyOwner {
    bytes memory projectTokenByteCode = getTokenBytecode(_name, _symbol);
    address projectTokenAddress = getAddress(projectTokenByteCode);
    deploy(projectTokenByteCode);

    bytes memory poolsByteCode = getPoolsBytecode(ERC20(projectTokenAddress));
    address poolsAddress = getAddress(poolsByteCode);
    deploy(poolsByteCode);

    poolsAddresses.push(poolsAddress);
    poolsData[poolsAddress] = Pool(projectTokenAddress, _poolName);
    emit NewPool(poolsAddress);
  }
}