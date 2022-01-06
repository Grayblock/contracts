pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Token.sol";
import "./Pools.sol";
import "./Factory.sol";
import "./lib/Address.sol";

contract PoolsFactory is Factory, Ownable {
    address[] public poolsAddresses;

    uint256 constant SALT = 0xff;

    struct PoolData {
        string poolName;
        string projectTokenName;
        string projectTokenSymbol;
        uint256 totalTokenAmount;
        uint256 startingTime;
        uint256 goal;
        uint256 cap;
        address executor;
    }

    event PoolDeployed(address _pool);

    constructor(IERC20 _tradeToken) {
        tradeToken = _tradeToken;
    }

    function getTokenBytecode(string memory _name, string memory _symbol)
        public
        view
        returns (bytes memory)
    {
        bytes memory creationCode = type(Token).creationCode;
        return Address.getByteCode(abi.encode(_name, _symbol), creationCode);
    }

    function getPoolsBytecode(Token _projectToken, string memory _name)
        public
        view
        returns (bytes memory)
    {
        bytes memory creationCode = type(Pools).creationCode;
        return
            Address.getByteCode(
                abi.encode(_projectToken, tradeToken, _name),
                creationCode
            );
    }

    function getAddress(bytes memory _bytecode) public view returns (address) {
        return Address.getAddress(_bytecode, address(this));
    }

    function _deploy(bytes memory bytecode) internal {
        address addr;

        assembly {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), SALT)

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
    }

    function deployAndCreatePool(PoolData calldata _poolData)
        external
        onlyOwner
    {
        bytes memory projectTokenByteCode = getTokenBytecode(
            _poolData.projectTokenName,
            _poolData.projectTokenSymbol
        );
        address projectTokenAddress = getAddress(projectTokenByteCode);
        _deploy(projectTokenByteCode);

        bytes memory poolsByteCode = getPoolsBytecode(
            Token(projectTokenAddress),
            _poolData.poolName
        );
        address poolsAddress = getAddress(poolsByteCode);
        _deploy(poolsByteCode);
        emit PoolDeployed(poolsAddress);

        poolsAddresses.push(poolsAddress);
        poolsData[poolsAddress] = Pool(projectTokenAddress, _poolData.poolName);

        _createPoolAndTransferOwnerships(
            poolsAddress,
            _poolData.totalTokenAmount,
            _poolData.startingTime,
            _poolData.goal,
            _poolData.cap,
            _poolData.executor
        );
    }

    function getPools() public view override returns (address[] memory) {
        return poolsAddresses;
    }

    function _createPoolAndTransferOwnerships(
        address _pool,
        uint256 _totalTokenAmount,
        uint256 _startingTime,
        uint256 _goal,
        uint256 _cap,
        address _executor
    ) internal {
        address projectToken = poolsData[_pool].projectToken;
        require(projectToken != address(0), "PoolsFactory: Invalid pool");

        Token(projectToken).transferOwnership(_pool);

        Pools(_pool).CreatePool(_totalTokenAmount, _startingTime, _goal, _cap);

        Pools(_pool)._setExecutor(_executor);
        Pools(_pool).transferOwnership(owner());
    }
}
