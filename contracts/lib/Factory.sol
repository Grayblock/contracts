pragma solidity ^0.8.0;

library Factory {
    uint256 constant SALT = 0xff;

    function getByteCode(bytes memory _hash, bytes memory _creationCode)
        public
        returns (bytes memory)
    {
        return abi.encodePacked(_creationCode, _hash);
    }

    function getAddress(bytes memory _bytecode) public returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                SALT,
                keccak256(_bytecode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }
}
