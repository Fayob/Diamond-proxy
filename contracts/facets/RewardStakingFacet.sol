// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Diamond } from "../Diamond.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { IERC721 } from "../interfaces/IERC721.sol";
import { IERC1155 } from "../interfaces/IERC1155.sol";

error YOU_HAVE_NO_REWARD();

contract RewardStakingFacet {
    function calculateRewards(address user) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 erc20Rewards = ds.erc20Stakes[user] * ds.baseAPR / 100;
        uint256 erc721Rewards = 5 * ds.baseAPR / 100; 
        uint256 erc1155Rewards = 5 * ds.baseAPR / 100; 
        return erc20Rewards + erc721Rewards + erc1155Rewards;
    }

    function claimRewards() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 reward = calculateRewards(msg.sender) * (10**18);
        if(reward <= 0) revert YOU_HAVE_NO_REWARD();
        ds.rewardBalances[msg.sender] = 0;
        // Diamond diamond = Diamond(address(this));
        // diamond.transfer(msg.sender, reward);
    }
}