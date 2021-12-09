pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Pools.sol";
import "./FactoryStorage.sol";
import "./lib/Factory.sol";

contract PoolsFactory is FactoryStorage, Ownable {
    address[] public poolsAddresses;
    address private admin;

    uint256 constant SALT = 0xff;

    event Deployed(address addr, uint256 salt);

    constructor(Token _tradeToken, address _admin) {
        tradeToken = _tradeToken;
        admin = _admin;
    }

    function getTokenBytecode(string memory _name, string memory _symbol)
        public
        view
        returns (bytes memory)
    {
        bytes memory creationCode = type(Token).creationCode;
        return Factory.getByteCode(abi.encode(_name, _symbol), creationCode);
    }

    function getPoolsBytecode(Token _projectToken)
        public
        view
        returns (bytes memory)
    {
        bytes memory creationCode = type(Pools).creationCode;
        return
            Factory.getByteCode(
                abi.encode(_projectToken, tradeToken),
                creationCode
            );
    }

    function getAddress(bytes memory _bytecode) public view returns (address) {
        return Factory.getAddress(_bytecode, address(this));
    }

    function _deploy(bytes memory bytecode) internal {
        address addr;

        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), SALT)

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deployed(addr, SALT);
    }

    function deployPool(
        string memory _poolName,
        string memory _name,
        string memory _symbol
    ) external onlyOwner {
        bytes memory projectTokenByteCode = getTokenBytecode(_name, _symbol);
        address projectTokenAddress = getAddress(projectTokenByteCode);
        _deploy(projectTokenByteCode);

        bytes memory poolsByteCode = getPoolsBytecode(
            Token(projectTokenAddress)
        );
        address poolsAddress = getAddress(poolsByteCode);
        _deploy(poolsByteCode);

        poolsAddresses.push(poolsAddress);
        poolsData[poolsAddress] = Pool(projectTokenAddress, _poolName);
        emit NewPool(poolsAddress);
    }

    function getPools() public view returns (address[] memory) {
        return poolsAddresses;
    }

    function createPoolAndTransferOwnerships(
        address _pool,
        uint256 _totalTokenAmount,
        uint256 _startingTime,
        uint256 _goal,
        uint256 _cap
    ) external onlyOwner {
        address projectToken = poolsData[_pool].projectToken;
        require(projectToken != address(0), "PoolsFactory: Invalid pool");

        Token(projectToken).transferOwnership(_pool);

        Pools(_pool).CreatePool(_totalTokenAmount, _startingTime, _goal, _cap);

        Pools(_pool).transferOwnership(admin);
    }
}
