pragma solidity ^0.8.0;

import './Token.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "./Pools.sol";

contract PoolsFactory is Ownable {
  Token public tradeToken;
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

  constructor(Token _tradeToken, address _admin) {
    tradeToken = _tradeToken;
    admin = _admin;
  }

  function getTokenBytecode(
    string memory _name,
    string memory _symbol
  ) public pure returns (bytes memory) {
    bytes memory bytecode = type(Token).creationCode;

    return abi.encodePacked(bytecode, abi.encode(_name, _symbol));
  }

  function getPoolsBytecode(
    Token _projectToken
  ) public view returns (bytes memory) {
    bytes memory bytecode = type(Pools).creationCode;

    return abi.encodePacked(bytecode, abi.encode(_projectToken, tradeToken));
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

  function deployPool(string memory _poolName, string memory _name, string memory _symbol) external onlyOwner {
    bytes memory projectTokenByteCode = getTokenBytecode(_name, _symbol);
    address projectTokenAddress = getAddress(projectTokenByteCode);
    deploy(projectTokenByteCode);

    bytes memory poolsByteCode = getPoolsBytecode(Token(projectTokenAddress));
    address poolsAddress = getAddress(poolsByteCode);
    deploy(poolsByteCode);

    poolsAddresses.push(poolsAddress);
    poolsData[poolsAddress] = Pool(projectTokenAddress, _poolName);
    emit NewPool(poolsAddress);
  }

  function createPoolAndTransferOwnerships(address _pool, uint256 _totalTokenAmount, 
        uint256 _startingTime, 
        uint256 _goal,
        uint256 _cap) external onlyOwner {
          address projectToken = poolsData[_pool].projectToken;
          require(projectToken != address(0), "PoolsFactory: Invalid pool");

          require(Token(projectToken).approve(_pool, _totalTokenAmount), "PoolsFactory: FAILED to approve");
          
          Pools(_pool).CreatePool(_totalTokenAmount, _startingTime, _goal, _cap);

        
          uint256 balance = Token(projectToken).balanceOf(address(this));
          // send balance from address(this) to admin
          Token(projectToken).transfer(admin, balance);

          // transfer ownerships of pool and project token to admin
          Pools(_pool).transferOwnership(admin);
          Token(projectToken).transferOwnership(admin);
        }
}