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
    
#     user1 = accounts.load("user1")

#     man.buyTokens(3,{'from':user1, 'value':30})
#     print(man.state)

def main():
    user1 = accounts.load("user1")
    acct=accounts.load("AAVE")
    A = Token.at("0xC641B9df0209Be9693250679f3Ce869463Cf9Bb6")
    man = Manager.at("0x314caA8c71d743973c8c0044BA49597f24718de1")
    man.requestState("0x4712020ca7e184c545fd2483696c9dc36cb7c36a","ca0d86424890466f856de3e868087f81",{'from': acct})
    
#     #man.redeem(A,2,{'from':acctClient})
