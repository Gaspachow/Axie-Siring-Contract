// SPDX-License-Identifier: I don't know, bro...
pragma solidity 0.6.12;

import "./AxiesTransfer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract AxiesSiring is AxiesTransfer {

	using SafeMath for uint256;

	IERC20 public constant SLP = IERC20(0x37236CD05b34Cc79d3715AF2383E96dd7443dCF1);

	mapping (address => uint256) public SLPBalance;
	uint256 contractCut;


	event AxieRented(uint256 axieId);
	event AxieDoubleRented(uint256 axieId1, uint256 axieId2);

	function _getBreedingSLPCost(uint256 _axieIdA, uint256 _axieIdB) private view returns(uint256 totalCost) {
		(,uint256 _costA) = AXIE_BREEDING.requirementsForBreeding(_axieIdA);
		(,uint256 _costB) = AXIE_BREEDING.requirementsForBreeding(_axieIdB);
		uint256 _totalCost = _costA.add(_costB);
		return (_totalCost);
	}

	function _payFee(uint256 _fee, address axieOwner) private {
		uint256 _ownerCut;
		if (_fee > 2) {
			uint256 _takenCut = _fee.mul(5);
			_takenCut = _takenCut.div(100);
			_ownerCut = _fee - (_takenCut); //safe because _TakenCut is approx 0.25 the fee calculated with safemath above.
			contractCut = contractCut.add(_takenCut);
		} else {
			_ownerCut = _fee;
		}
		SLPBalance[axieOwner] = SLPBalance[axieOwner].add(_ownerCut);
	}

	function rentOneAxie(uint256 _ownerAxieId, uint256 _rentedAxieId, uint256 _birthplace, bool _useBalance) external whenNotPaused payable {
		// function variables
		uint256 _breedingCost = _getBreedingSLPCost(_ownerAxieId, _rentedAxieId);
		AxieOffer storage _rentedAxieOffer = axieToOffer[_rentedAxieId];
		uint256 _totalSLPCost = _breedingCost + _rentedAxieOffer.ownerFee;

		//check
		// require(msg.value == AXIE_BREEDING.breedingFee()); --------- (checked by the AXIE_BREEDING breedOwnedAxies below)
		// require(SLP.balanceOf(msg.sender) >= _totalSLPCost); ------- (checked by the SLP.transferFrom below)
		require(_rentedAxieOffer.maxBreeds > 0, "AxiesSiring: The rented Axie is not allowed to breed through this contract any more.");

		//effect
		axieToOffer[_rentedAxieId].maxBreeds--; //safe because the check above (maxBreeds > 0) asserts that (b <= a) in (a - b) scenario.
		if (_useBalance) {
			uint256 _prevBalance = SLPBalance[msg.sender];
			if (_prevBalance >= _totalSLPCost) {
				SLPBalance[msg.sender] = _prevBalance.sub(_totalSLPCost);
				_totalSLPCost = 0;
			} else {
				SLPBalance[msg.sender] = 0;
				_totalSLPCost = _totalSLPCost.sub(_prevBalance);
			}
		}

		//interact
		AXIE_CORE.safeTransferFrom(msg.sender, address(this), _ownerAxieId);
		if (_totalSLPCost > 0) {
			SLP.transferFrom(msg.sender, address(this), _totalSLPCost);
		}
		_payFee(uint256(_rentedAxieOffer.ownerFee), _rentedAxieOffer.owner);
		uint256 _babyAxieId = AXIE_BREEDING.breedOwnedAxies{value:msg.value}(_ownerAxieId, _rentedAxieId, _birthplace);
		AXIE_CORE.safeTransferFrom(address(this), msg.sender, _ownerAxieId);
		AXIE_CORE.safeTransferFrom(address(this), msg.sender, _babyAxieId);
		//event trigger
		emit AxieRented(_rentedAxieId);
	}

	function rentTwoAxies(uint256 _rentedAxieId1, uint256 _rentedAxieId2, uint256 _birthplace, bool _useBalance) external whenNotPaused payable {
		// function variables
		uint256 _breedingCost = _getBreedingSLPCost(_rentedAxieId1, _rentedAxieId2);
		AxieOffer storage _rentedAxieOffer1 = axieToOffer[_rentedAxieId1];
		AxieOffer storage _rentedAxieOffer2 = axieToOffer[_rentedAxieId2];
		uint256 _totalSLPCost = _breedingCost + _rentedAxieOffer1.ownerFee + _rentedAxieOffer2.ownerFee;

		//check
		// require(msg.value == AXIE_BREEDING.breedingFee()); --------- (checked by the AXIE_BREEDING breedOwnedAxies below)
		// require(SLP.balanceOf(msg.sender) >= _totalSLPCost); ------- (checked by the SLP.transferFrom below)
		require(_rentedAxieOffer1.maxBreeds > 0, "AxiesSiring: The first rented Axie is not allowed to breed through this contract any more.");
		require(_rentedAxieOffer2.maxBreeds > 0, "AxiesSiring: The second rented Axie is not allowed to breed through this contract any more.");

		//effect
		axieToOffer[_rentedAxieId1].maxBreeds--; //safe because the check above (maxBreeds > 0) asserts that (a >= b) in (a - b) scenario.
		axieToOffer[_rentedAxieId2].maxBreeds--;
		if (_useBalance) {
			uint256 _prevBalance = SLPBalance[msg.sender];
			if (_prevBalance >= _totalSLPCost) {
				SLPBalance[msg.sender] = _prevBalance.sub(_totalSLPCost);
				_totalSLPCost = 0;
			} else {
				SLPBalance[msg.sender] = 0;
				_totalSLPCost = _totalSLPCost.sub(_prevBalance);
			}
		}

		//interact
		if (_totalSLPCost > 0) {
			SLP.transferFrom(msg.sender, address(this), _totalSLPCost);
		}
		_payFee(uint256(_rentedAxieOffer1.ownerFee), _rentedAxieOffer1.owner);
		_payFee(uint256(_rentedAxieOffer2.ownerFee), _rentedAxieOffer2.owner);
		uint256 _babyAxieId = AXIE_BREEDING.breedOwnedAxies{value:msg.value}(_rentedAxieId1, _rentedAxieId2, _birthplace);
		AXIE_CORE.safeTransferFrom(address(this), msg.sender, _babyAxieId);
		//event trigger
		emit AxieDoubleRented(_rentedAxieId1, _rentedAxieId2);
	}


	//V0.1 of claiming SLP balance.

	function getSLPBalance(address _balanceOwner) view public returns(uint256 balance){
		return (SLPBalance[_balanceOwner]);
	}

	function claimSLP() external {
		uint256 _balance = SLPBalance[msg.sender];
		SLPBalance[msg.sender].sub(_balance);
		SLP.transferFrom(address(this), msg.sender, _balance);
	}

	function claimContractCut() external {
		// TO-DO
	}
}
