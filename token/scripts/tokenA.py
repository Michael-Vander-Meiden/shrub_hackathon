from brownie import Token, accounts


def main():
    acct=accounts.load("AAVE")
    return Token.deploy("Token A", "TOKA", 18, 1e21, {'from': acct})
