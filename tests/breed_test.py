from brownie import accounts
import brownie
from brownie import Wei

def test_breedOneTwo(slp_token, minter, slp_bank, axie, siring):
    # Initialization
    slp_token.transfer(minter, 300000, {'from':slp_bank})
    axie.setApprovalForAll(siring, True, {'from': minter})
    slp_token.approve(siring, 100000000000)
    
    # Check ownership transfer
    siring.supplyAxie(145975, 100, 2, {'from': minter})
    assert axie.ownerOf(145975) == siring

    # Check that an axie has been created, and minter owns egg and his axie back
    supply = axie.totalSupply()
    tx = siring.rentOneAxie(144275, 145975, 0, False, {'from':minter, 'value':Wei("0.005 ether")})
    assert axie.totalSupply() == supply + 1
    assert axie.ownerOf(tx.events['AxieRented']['babyId']) == minter
    assert axie.ownerOf(144275) == minter

    # Check ownership transfer
    siring.supplyAxie(144275, 100, 1, {'from': minter})
    assert axie.ownerOf(144275) == siring

    # Check that an axie has been created, and minter owns egg
    supply = axie.totalSupply()
    tx = siring.rentTwoAxies(145975, 144275, 0, False, {'from':minter, 'value': Wei("0.005 ether")})
    assert axie.totalSupply() == supply + 1
    assert axie.ownerOf(tx.events['AxieDoubleRented']['babyId']) == minter

def test_failbreed(slp_token, minter, slp_bank, axie, siring):
    with brownie.reverts("AxiesSiring: The first rented Axie is not allowed to breed through this contract any more."):
        siring.rentTwoAxies(145975, 144275, 0, False, {'from':minter, 'value': Wei("0.005 ether")})