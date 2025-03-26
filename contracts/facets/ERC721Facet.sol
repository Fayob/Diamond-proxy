// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "../interfaces/IERC721.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

error NOT_A_STAKED_TOKEN();

contract ERC721Facet {
    function addERC721Stake(address token, uint256 tokenId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        IERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
        ds.erc721Stakes[msg.sender][tokenId] = true;
    }

    function removeERC721Stake(address token, uint256 tokenId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(!ds.erc721Stakes[msg.sender][tokenId]) revert NOT_A_STAKED_TOKEN();
        ds.erc721Stakes[msg.sender][tokenId] = false;
        IERC721(token).safeTransferFrom(address(this), msg.sender, tokenId);
    }
}