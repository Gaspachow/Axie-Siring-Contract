from brownie import accounts
import brownie
from brownie import Wei

def test_breed(slp_token, minter, slp_bank, axie, siring, breed):
    slp_token.transfer(minter, 300000, {'from':slp_bank})
    axie.setApprovalForAll(siring, True, {'from': minter})
    siring.supplyAxie(145975, 100, 2, {'from': minter})
    siring.supplyAxie(144275, 100, 2, {'from': minter})
    supply = axie.totalSupply()
    slp_token.approve(siring, 100000000000)
    siring.rentTwoAxies(145975, 144275, 0, True, {'from':minter, 'value': Wei("0.005 ether")})
    assert axie.totalSupply() == supply + 1
