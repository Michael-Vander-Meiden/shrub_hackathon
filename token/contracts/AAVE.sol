pragma solidity ^0.6.12;


import "protocol-v2-master/contracts/protocol/configuration/LendingPoolAddressesProvider.sol";
import "protocol-v2-master/contracts/protocol/lendingpool/LendingPool.sol";
import "protocol-v2-master/contracts/misc/WETHGateway.sol";


contract AAVE {
   
    LendingPoolAddressesProvider provider;
    WETHGateway gateway;

    constructor(address _provider, address payable _gateway ) public {
        
        provider = LendingPoolAddressesProvider(_provider);
        gateway = WETHGateway(_gateway);


    }

function deposit() public payable {
    LendingPool lendingpool = LendingPool(provider.getLendingPool());
    gateway.depositETH.value(msg.value)(address(lendingpool) ,address(this), 0);
    // gateway.depositETH.value(msg.value)(address(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe) ,address(this), 0);

    }

function depositToken(uint256 _amount) public payable {
    LendingPool lendingpool = LendingPool(provider.getLendingPool());
    address Token = address(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD); //Needs to be dai address
    lendingpool.deposit(Token,_amount,address(this),0);
}

}
