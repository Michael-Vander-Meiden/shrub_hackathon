from brownie import Token, accounts, Manager, AAVE

def main():
    acct=accounts.load("AAVE")
    A=AAVE.deploy("0x88757f2f99175387ab4c6a4b3067c77a695b0349", "0xf8aC10E65F2073460aAD5f28E1EABE807DC287CF", {'from': acct})

    # A.deposit({"from":acct,"value":1000000,"gas_limit":1250000, "allow_revert":True})
    A.depositDAI(100,{"from":acct,"gas_limit":1250000,"allow_revert":True})


