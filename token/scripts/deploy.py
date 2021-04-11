from brownie import Token, Manager, accounts


def main():
    acct=accounts.load("AAVE")
    A=Token.deploy("Token A", "TOKA", 18, 0, {'from': acct})
    B=Token.deploy("Token B", "TOKB", 18, 0, {'from': acct})
    Stable = Token.deploy("Dai Stablecoin", "Dai", 18, 10000000000, {'from': acct})
    man=Manager.deploy(A, B, Stable, 10, 0,{'from': acct})

    A.transferPower(man, {'from':acct})
    B.transferPower(man, {'from':acct})
    
    #user1 = accounts.load("user1")