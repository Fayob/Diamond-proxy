// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC1155} from "../interfaces/IERC1155.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

error NOT_ENOUGH_BALANCE();

contract ERC1155StakingFacet {
    function addERC1155Stake(address token, uint256 tokenId, uint256 amount) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        ds.erc1155Stakes[msg.sender][tokenId] += amount;
    }

    function removeERC1155Stake(address token, uint256 tokenId, uint256 amount) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(ds.erc1155Stakes[msg.sender][tokenId] < amount) revert NOT_ENOUGH_BALANCE();
        ds.erc1155Stakes[msg.sender][tokenId] -= amount;
        IERC1155(token).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
    }
}