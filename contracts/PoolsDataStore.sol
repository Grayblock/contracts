pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolsDataStore is Ownable {
    bytes32 public constant BACKGROUND_IMAGE_URL =
        0x123454c74b0c1a91e08303d2e10c9eb01319b4900505a71e532a0aee29c19a09; // keccak256("BACKGROUND_IMAGE_URL")

    bytes32 public constant PROJECT_TOKEN_IMAGE_URL =
        0x55129d5b89fe8fdf602cd1675ce1628109d1f3853766f40ccabaeffd2319c57a; // keccak256("PROJECT_TOKEN_IMAGE_URL")

    bytes32 public constant ENERGY_GENERATION_CAPACITY =
        0xaffae347521bc0359897a5609f87526f6fba7883f17879084135a7128ec80675; // keccak256("ENERGY_GENERATION_CAPACITY")

    bytes32 public constant ESTIMATED_CAPACITY_FACTOR =
        0xc8ab0af5d2eae4b5d01c409cbc009d7dd3f94b57ad48ed91d23feb87207a2593; // keccak256("ESTIMATED_CAPACITY_FACTOR")

    bytes32 public constant PROJECT_PDF_URL =
        0x223876cf2efde323fe21f9df046d159db51b1da29d53637ed116a3fba317313e; // keccak256("PROJECT_PDF_URL")

    mapping(address => mapping(bytes32 => string)) private dataStore;

    function _set(
        address _pool,
        bytes32 _key,
        string memory _value
    ) external onlyOwner {
        dataStore[_pool][_key] = _value;
    }

    function _get(address _pool, bytes32 _key)
        external
        view
        onlyOwner
        returns (string memory)
    {
        return dataStore[_pool][_key];
    }
}
