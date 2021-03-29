def test_mint_new_tokens(accounts, token):
    total_supply = token.totalSupply()
    acc_balance = token.balanceOf(accounts[0])
    token.mint(accounts[0], 500, {'from': accounts[0]})

    assert token.totalSupply() == total_supply + 500
    assert token.balanceOf(accounts[0]) == acc_balance + 500