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

interface AxieBreeding {
	function breedOwnedAxies(uint256 _sireId, uint256 _matronId, uint256 _birthPlace) external payable returns(uint256);
	function growToPetiteAxie(uint256 _axieId) external;
	function growToAdultAxie(uint256 _axieId) external;
	function breedingFee() external returns(uint256);
	function getAxieStage(uint256 _axieId) external view returns(uint256);
	function getBreedingLimit() external view returns(uint256 _limit);
	function requirementsForBreeding(uint256 _axieId) external view returns(uint256 _numBreeding, uint256 _potionsRequired);
}

contract AxiesTransfer is Ownable, Pausable {

	AxieCore public constant AXIE_CORE = AxieCore(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d);
	AxieExtraData public constant AXIE_EXTRA = AxieExtraData(0x10e304a53351B272dC415Ad049Ad06565eBDFE34);
	AxieBreeding public constant AXIE_BREEDING = AxieBreeding(0x01AAc5236Ad205ebBe4F6819bC64eF5BeF40b71c);

	event AxieDeposit(uint axieId, uint128 ownerFee);
	event AxieRemoval(uint axieId);

	struct AxieOffer {
 		uint128 ownerFee;
 		address owner;
  }

	mapping (uint256 => AxieOffer) public axieToOffer;

	function supplyAxie(uint256 _axieId, uint128 _ownerFee) external whenNotPaused {
		AXIE_CORE.safeTransferFrom(msg.sender, address(this), _axieId);
		axieToOffer[_axieId] = AxieOffer(_ownerFee, msg.sender);
		emit AxieDeposit(_axieId, _ownerFee);
	}
}
