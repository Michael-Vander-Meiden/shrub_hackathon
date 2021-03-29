# Manager deployment test
def test_manager_deploy(Manager, accounts, token, tokenB):
    manager = Manager.deploy(token, tokenB, 100, 0, {'from': accounts[0]})

    assert manager.state() == 0


#Transfer power test
def test_transfer_power(manager, token, tokenB, accounts):
    assert token.token_admin() == accounts[0]
    token.transferPower(manager, {'from': accounts[0]})
    tokenB.transferPower(manager, {'from': accounts[0]})
    assert token.token_admin() == manager
    #test minting after power transfer
    manager.buyTokens(10, {'from': accounts[1], 'value': 1000})
    assert token.balanceOf(accounts[1], {'from': accounts[0] == 10})

    #TODO assert totalsupply before and after mint
