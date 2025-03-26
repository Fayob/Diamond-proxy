// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "../interfaces/IERC20.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";


contract ERC20TokenFacet {

    error AMOUNT_MUST_BE_GREATER_THAN_ZERO();
    error NOT_ENOUGH_BALANCE();
    function addERC20Stake(address token, uint256 amount) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(amount <= 0) revert AMOUNT_MUST_BE_GREATER_THAN_ZERO();
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        ds.erc20Stakes[msg.sender] += amount;
    }

    function removeERC20Stake(address token, uint256 amount) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(ds.erc20Stakes[msg.sender] <= 0) revert NOT_ENOUGH_BALANCE();
        ds.erc20Stakes[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
    }
}
