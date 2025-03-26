// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/interfaces/IERC20.sol";
// Foundry-Hardhat-Diamonds/lib/forge-std/src/test
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import { ERC20 } from "../contracts/token/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MTK", 18, 1_000_000) {
        mint(1_000_000 ether);
    }
}

// contract MockERC721 is ERC721 {
//     constructor() ERC721("Mock NFT", "MNFT") {}
//     function mint(address to, uint256 tokenId) external {
//         _mint(to, tokenId);
//     }
// }

// contract MockERC1155 is ERC1155 {
//     constructor() ERC1155("") {}
//     function mint(address to, uint256 id, uint256 amount) external {
//         _mint(to, id, amount, "");
//     }
// }

contract StakingDiamondTest is Test {
    Diamond diamond;
    ERC20TokenFacet erc20Facet;
    IERC20 testToken;

    address user = address(1);

    function setUp() public {
        // Deploy Diamond contract (assuming it includes ERC20 logic)
        diamond = new Diamond(address(this), address(0), "Diamond Token", "DMT", 1_000_000 ether);
        erc20Facet = ERC20TokenFacet(address(diamond));

        // Deploy a mock ERC20 token for staking
        testToken = new MockERC20();
        testToken.mint(1000 ether);

        // Approve the diamond contract to spend tokens on behalf of the user
        vm.startPrank(user);
        testToken.approve(address(diamond), 10 ether);
        vm.stopPrank();
    }

    function testAddERC20Stake() public {
        vm.startPrank(user);

        uint256 initialBalance = testToken.balanceOf(user);
        uint256 stakeAmount = 100 ether;

        erc20Facet.addERC20Stake(address(testToken), stakeAmount);

        uint256 finalBalance = testToken.balanceOf(user);
        uint256 contractBalance = testToken.balanceOf(address(diamond));

        assertEq(finalBalance, initialBalance - stakeAmount, "User balance should decrease");
        assertEq(contractBalance, stakeAmount, "Contract should receive the tokens");

        vm.stopPrank();
    }

    function testAddERC20Stake_ZeroAmount() public {
        vm.startPrank(user);

        vm.expectRevert(ERC20TokenFacet.AMOUNT_MUST_BE_GREATER_THAN_ZERO.selector);
        erc20Facet.addERC20Stake(address(testToken), 0);

        vm.stopPrank();
    }

    function testRemoveERC20Stake() public {
        vm.startPrank(user);

        uint256 stakeAmount = 100 ether;
        erc20Facet.addERC20Stake(address(testToken), stakeAmount);

        uint256 initialBalance = testToken.balanceOf(user);
        erc20Facet.removeERC20Stake(address(testToken), stakeAmount);

        uint256 finalBalance = testToken.balanceOf(user);
        uint256 contractBalance = testToken.balanceOf(address(diamond));

        assertEq(finalBalance, initialBalance, "User balance should be restored");
        assertEq(contractBalance, 0, "Contract balance should be zero");

        vm.stopPrank();
    }

    function testRemoveERC20Stake_InsufficientBalance() public {
        vm.startPrank(user);

        vm.expectRevert(ERC20TokenFacet.NOT_ENOUGH_BALANCE.selector);
        erc20Facet.removeERC20Stake(address(testToken), 50 ether);

        vm.stopPrank();
    }
    // Diamond stakingDiamond;
    // MockERC20 mockERC20;
    // DiamondCutFacet dCutFacet;
    // // MockERC721 mockERC721;
    // // MockERC1155 mockERC1155;
    // address user = address(1);

    // function setUp() public {
    //     address contractOwner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    //     stakingDiamond = new Diamond(contractOwner, address(dCutFacet), "staking diamond", "sdc", 1_000_000 ether);
    //     mockERC20 = new MockERC20();
    //     // mockERC721 = new MockERC721();
    //     // mockERC1155 = new MockERC1155();
    //     vm.deal(user, 10 ether); // Fund test user with ETH
    // }

    // function testStakeERC20() public {
    //     vm.startPrank(user);
    //     mockERC20.approve(address(stakingDiamond), 100 ether);
    //     stakingDiamond.stakeERC20(address(mockERC20), 100 ether);
    //     uint256 stakedBalance = stakingDiamond.erc20Stakes(user);
    //     assertEq(stakedBalance, 100 ether, "ERC20 stake incorrect");
    //     vm.stopPrank();
    // }

    // function testStakeERC721() public {
    //     vm.startPrank(user);
    //     // mockERC721.mint(user, 1);
    //     // mockERC721.approve(address(stakingDiamond), 1);
    //     // stakingDiamond.stakeERC721(address(mockERC721), 1);
    //     bool isStaked = stakingDiamond.erc721Stakes(user, 1);
    //     assertTrue(isStaked, "ERC721 stake failed");
    //     vm.stopPrank();
    // }

    // function testStakeERC1155() public {
    //     vm.startPrank(user);
    //     // mockERC1155.mint(user, 1, 5);
    //     // mockERC1155.setApprovalForAll(address(stakingDiamond), true);
    //     // stakingDiamond.stakeERC1155(address(mockERC1155), 1, 5);
    //     uint256 stakedAmount = stakingDiamond.erc1155Stakes(user, 1);
    //     assertEq(stakedAmount, 5, "ERC1155 stake incorrect");
    //     vm.stopPrank();
    // }

    // function testClaimRewards() public {
    //     vm.startPrank(user);
    //     mockERC20.approve(address(stakingDiamond), 100 ether);
    //     stakingDiamond.stakeERC20(address(mockERC20), 100 ether);
    //     uint256 rewards = stakingDiamond.calculateRewards(user);
    //     stakingDiamond.claimRewards();
    //     uint256 rewardBalance = stakingDiamond.balanceOf(user);
    //     assertEq(rewardBalance, rewards, "Incorrect reward amount");
    //     vm.stopPrank();
    // }
}
