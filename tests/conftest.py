import pytest


@pytest.fixture()
def minter(accounts):
    return accounts.at("0xf521Bb7437bEc77b0B15286dC3f49A87b9946773", force=True)

@pytest.fixture()
def slp_bank(accounts):
    return accounts.at("0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be", force=True)

@pytest.fixture()
def axie(interface):
    return interface.AxieCore1("0xf5b0a3efb8e8e4c201e2a935f110eaaf3ffecb8d")

@pytest.fixture()
def siring(AxiesSiring, accounts):
    return AxiesSiring.deploy({'from':accounts[0]})

@pytest.fixture()
def breed(interface):
    return interface.AxieBreeding("0x01AAc5236Ad205ebBe4F6819bC64eF5BeF40b71c")

@pytest.fixture()
def slp_token(interface, minter):
    return interface.ERC20("0x37236cd05b34cc79d3715af2383e96dd7443dcf1", owner=minter)
