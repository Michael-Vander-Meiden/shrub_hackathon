from brownie import Token, accounts


def main():
    return Manager.deploy("A", "B", 10, "active")
