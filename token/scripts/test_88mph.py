from brownie import Token, Manager, test88MPH, accounts


def main():
    
    # A=Token.deploy("Token A", "TOKA", 18, 0, {'from': acct})
    # B=Token.deploy("Token B", "TOKB", 18, 0, {'from': acct})
    # StableCoin = Token.deploy("Dai Stablecoin", "Dai", 18, 30000000000, {'from': acct})
    # test88mph = test88MPH.deploy(StableCoin, {'from':acct})
    
    # man=Manager.deploy(A, B, StableCoin, test88mph, 1, 0,{'from': acct})
    # man = 
    # A.transferPower(man, {'from':acct})
    # B.transferPower(man, {'from':acct})
    
    # StableCoin.transfer(test88mph, 10000000000, {'from':acct})

    # StableCoin.approve(man, 1000, {'from':acct})
    #man.buyTokens(1000, {'from':acct})
    acct=accounts.load("AAVE")
    man = Manager.at("0x02a39c01F5e852e2f00cD2979B427370266aA540")
    man.admin88mphDeposit(2000, 9827349238, {'from':acct})
    man.admin88mphWithdraw(293847983, 29384, {'from':acct})

    
#     man.redeem({'from':acct})



#     #user1 = accounts.load("user1")

# def main():
#     man = Manager.at("0xE06D9Dcf0078736E20e91DE90F4B145eAd54652b")
#     acct=accounts.load("AAVE")
    
#     man.redeem({'from':acct})

# def main():
#     man = Manager.at("0xE06D9Dcf0078736E20e91DE90F4B145eAd54652b")
#     StableCoin = Token.at("0x3E12f2860a91536db4BD7f22f7b286520BAcb827")
#     test88mph = test88MPH.at("0x7586d5ce17Db6DC65BA9A2f4e24974b294275Cd5")
    
#     acct=accounts.load("AAVE")
#     print(StableCoin.balanceOf(acct))
#     print(StableCoin.balanceOf(man))
#     print(StableCoin.balanceOf(test88mph))
    
