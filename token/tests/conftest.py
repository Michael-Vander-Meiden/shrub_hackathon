#!/usr/bin/python3

import pytest


@pytest.fixture(scope="function", autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="module")
def token(Token, accounts):
    return Token.deploy("Test Token", "TST", 18, 1e21, {'from': accounts[0]})

@pytest.fixture(scope="module")
def tokenB(Token, accounts):
    return Token.deploy("Test Token B", "TSTB", 18, 1e21, {'from': accounts[0]})

@pytest.fixture(scope="module")
def manager(Manager, accounts, token, tokenB):
    return Manager.deploy(token, tokenB, 100, 0, {'from': accounts[0]})