pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "./Pools.sol";

contract PoolsFactory is Ownable {
  ERC20 public tradeToken;
  Pools[] public poolsAddresses;
  address private admin;

  uint256 constant SALT = 0xff;

  event Deployed(address addr, uint256 salt);

  constructor(ERC20 _tradeToken, address _admin) public {
    tradeToken = _tradeToken;
    admin = _admin;
  }

  function getTokenBytecode(
    address _owner,
    string memory _name,
    string memory _symbol
  ) public pure returns (bytes memory) {
    bytes memory bytecode = type(ERC20).creationCode;

    return abi.encodePacked(bytecode, abi.encode(_name, _symbol));
  }

  function getAddress(bytes memory bytecode, uint256 _salt)
    public
    view
    returns (address)
  {
    bytes32 hash = keccak256(
      abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
    );

    // NOTE: cast last 20 bytes of hash to address
    return address(uint160(uint256(hash)));
  }

  function deploy(bytes memory bytecode) public payable {
    address addr;

    assembly {
      addr := create2(0, add(bytecode, 0x20), mload(bytecode), SALT)

      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }

    emit Deployed(addr, SALT);
  }
}