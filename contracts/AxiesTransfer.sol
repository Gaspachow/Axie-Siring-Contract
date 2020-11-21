// SPDX-License-Identifier: I don't know, bro...
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface AxieExtraData {
	function getExtra(uint256 _axieId) external view returns (uint256, uint256, uint256, uint256 /* breed count */);
}

interface AxieCore is IERC721 {
	function getAxie(uint256 _axieId) external view returns (uint256 _genes, uint256 _bornAt);
}

contract AxiesTransfer is Ownable, Pausable, IERC20 {

  AxieCore public constant AXIE_CORE = AxieCore(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d);
  AxieExtraData public constant AXIE_EXTRA = AxieExtraData(0x10e304a53351B272dC415Ad049Ad06565eBDFE34);

  event AxieDeposit(uint axieId, uint128 ownerFee);
  event AxieRemoval(uint axieId);

  struct AxieOffer {
    uint128 ownerFee;
    address owner;
  }

  mapping (uint256 => AxieOffer) public axieToOffer;

}
