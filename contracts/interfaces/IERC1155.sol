// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1155 {
  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
  function balanceOf(address _owner, uint256 _id) external view returns (uint256);

}