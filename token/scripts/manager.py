from brownie import Token, accounts, ShrubManager


def main():
    A=Token.deploy("Token A", "TOKA", 18, 1e21, {'from': accounts[0]})
    B=Token.deploy("Token B", "TOKB", 18, 1e21, {'from': accounts[0]})

    man=ShrubManager.deploy(A, B, 10, 0, {'from': accounts[0]})

    