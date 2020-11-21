import pytest


@pytest.fixture(scope="function", autouse=True)
def shared_setup(fn_isolation):
    pass


@pytest.fixture()
def minter(accounts):
    return accounts.at("0xf521Bb7437bEc77b0B15286dC3f49A87b9946773", force=True)


@pytest.fixture()
def userA(accounts):
    return accounts[1]


@pytest.fixture()
def userB(accounts):
    return accounts[2]


@pytest.fixture()
def slp_token(interface, minter):
    return interface.ERC20("0x37236cd05b34cc79d3715af2383e96dd7443dcf1", owner=minter)


@pytest.fixture()
def ygift(AxiesTransfer, minter):
    return AxiesTransfer.deploy({"from": minter})
