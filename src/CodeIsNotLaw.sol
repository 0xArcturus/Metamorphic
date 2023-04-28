pragma solidity ^0.8.17;

import "./ERC20.sol";

contract CodeIsNotLaw is ERC20("CodeIsNotLaw", "CINL", 18) {
    bytes32 public immutable correctCodeHash;

    constructor() {
        correctCodeHash = hex"c246029c9bd635997f6bc66218757d6ac3079199e2b088957a10854d6792adae";
    }

    function mint(address receiver) external {
        require(getContractCodeHash(receiver) == correctCodeHash, "code hash does not match");
        if (balanceOf[receiver] == 0) {
            _mint(receiver, 1);
        }
    }

    function getContractCodeHash(address contractAddress) public view returns (bytes32 contractCodeHash) {
        assembly {
            contractCodeHash := extcodehash(contractAddress)
        }
    }

    function getAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));
        return address(uint160(uint256(hash)));
    }
}
