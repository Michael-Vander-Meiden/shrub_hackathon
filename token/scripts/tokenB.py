#!/usr/bin/python3

from brownie import Token, accounts


def main():
    return Token.deploy("Token B", "TOKB", 18, 1e21, {'from': accounts[0]})
