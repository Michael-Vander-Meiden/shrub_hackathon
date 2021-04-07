from brownie import Token, accounts, ATestnetConsumer, updateState, Manager


# def main():
#     acct=accounts.load("AAVE")
#     return updateState.deploy({'from': acct})


## need to send link to new contract

# def main():
#     acct=accounts.load("AAVE")
#     test=updateState.at("0x1eaFF923d72EF35d012228fC8EdE79cF4747C796")
#     test.requestState("0x4712020ca7e184c545fd2483696c9dc36cb7c36a","ca0d86424890466f856de3e868087f81",{'from': acct})
#     print(test.currentState())


# def main():
#     acct=accounts.load("AAVE")
#     A=Token.deploy("Token A", "TOKA", 18, 1e21, {'from': acct})
#     B=Token.deploy("Token B", "TOKB", 18, 1e21, {'from': acct})
#     man=Manager.deploy(A, B, 10, 0,{'from': acct})

#     A.transferPower(man, {'from':acct})
#     B.transferPower(man, {'from':acct})
    
#     acctClient = accounts.load("client")
#     man.buyTokens(3,{'from':acctClient, 'value':30})

def main():
    acctClient = accounts.load("client")
    acct=accounts.load("AAVE")
    A = Token.at("0xa37f7eb8B97Bfb88c9B68384735d644447A5C387")
    man = Manager.at("0x5e414b6e1d8f8D0Ac27C1912D11C75Ed8568C8aE")
    # man.requestState("0x4712020ca7e184c545fd2483696c9dc36cb7c36a","ca0d86424890466f856de3e868087f81",{'from': acct})
    
    man.redeem(A,2,{'from':acctClient})
