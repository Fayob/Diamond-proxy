// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LibDiamond} from "./libraries/LibDiamond.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import { ERC20 } from "./token/ERC20.sol";

error INSUFFICIENT_BALANCE();
error ALLOWANCE_EXCEEDED();
error ONLY_OWNER_CAN_MINT();

contract Diamond {
    LibDiamond.DiamondStorage ds;
    constructor(
        address _contractOwner, 
        address _diamondCutFacet, 
        string memory _name, 
        string memory _symbol,
        uint256 _totalSupply
        ) payable {
        LibDiamond.setContractOwner(_contractOwner);
        ds.name = _name;
        ds.symbol = _symbol;
        ds.totalSupply = _totalSupply;

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");
    }

    function name() external view returns (string memory) {
        return ds.name;
    }

    function symbol() external view returns (string memory) {
        return ds.symbol;
    }

    function totalSupply() external view returns (uint256) {
        return ds.totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return ds.balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if(ds.balances[msg.sender] < amount) revert INSUFFICIENT_BALANCE();
        ds.balances[msg.sender] -= amount;
        ds.balances[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        ds.allowances[msg.sender][spender] = amount;
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return ds.allowances[_owner][_spender];
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (ds.balances[from] < amount) revert INSUFFICIENT_BALANCE();
        if(ds.allowances[from][msg.sender] < amount) revert ALLOWANCE_EXCEEDED();
        ds.balances[from] -= amount;
        ds.balances[to] += amount;
        ds.allowances[from][msg.sender] -= amount;
        return true;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == LibDiamond.contractOwner(), "Only owner can mint");
        if (msg.sender != LibDiamond.contractOwner()) revert ONLY_OWNER_CAN_MINT();
        ds.totalSupply += amount;
        ds.balances[to] += amount;
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    //immutable function example
    function example() public pure returns (string memory) {
        return "THIS IS AN EXAMPLE OF AN IMMUTABLE FUNCTION";
    }

    receive() external payable {}
}
