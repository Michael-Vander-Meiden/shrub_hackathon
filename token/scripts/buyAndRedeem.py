from brownie import Token, accounts, Manager

def main():

    # initialize
    A=Token.deploy("Token A", "TOKA", 18, 1e21, {'from': accounts[0]})
    B=Token.deploy("Token B", "TOKB", 18, 1e21, {'from': accounts[0]})
    man=Manager.deploy(A, B, 10, 0,{'from': accounts[0]})

    # transfer power to manager contract
    A.transferPower(man, {'from':accounts[0]})
    B.transferPower(man, {'from':accounts[0]})

    # buy tokens
    man.buyTokens(3,{'from':accounts[1], 'value':30})

    # check man eth balance, A, B tokens
    print(man.balance())
    print(A.balanceOf(accounts[1]))
    print(B.balanceOf(accounts[1]))

    # trigger triggered, token A has value
    man.trigger_triggered()

    # man.redeem(B,2,{'from':accounts[1]}) # check token B error
    # man.redeem(A,5,{'from':accounts[1]}) # check not enough tokens error

    # redeem 
    man.redeem(A,3,{'from':accounts[1]})
   
    # check man eth balance, A, B tokens
    print(man.balance())
    print(A.balanceOf(accounts[1]))
    print(B.balanceOf(accounts[1]))





