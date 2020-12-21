// SPDX-License-Identifier: I don't know, bro...
pragma solidity 0.6.12;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface AxieCore1 is IERC721 {
	function totalSupply() external view returns (uint256);
}