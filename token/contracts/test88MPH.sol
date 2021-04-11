pragma solidity ^0.6.0;

import "./Token.sol";
import "./SafeMath.sol";




contract test88MPH {
    
    Token public stableCoin;
    mapping(address => uint256) public deposit_records;

    constructor(Token _stableCoin) public {
        stableCoin = _stableCoin;
    }


    function deposit(uint256 amount, uint256 maturationTimestamp) external {
        uint _allowance = stableCoin.allowance(msg.sender, address(this));
        require(_allowance == amount);
        require(stableCoin.transferFrom(msg.sender, address(this), amount));
        deposit_records[msg.sender] = amount;
    }

    function withdraw(uint256 depositID, uint256 fundingID) external {
        require (deposit_records[msg.sender] > 0, "no record of deposit from this sender");
        uint256 interest = SafeMath.div(deposit_records[msg.sender], 10);
        uint256 withdraw_amount = deposit_records[msg.sender] + interest;
        require (stableCoin.transfer(msg.sender, withdraw_amount));
        deposit_records[msg.sender] = 0;

    }

    function earlyWithdraw(uint256 depositID, uint256 fundingID) external {
        require (deposit_records[msg.sender] > 0, "no record of deposit from this sender");
        uint256 withdraw_amount = deposit_records[msg.sender];
        require (stableCoin.transfer(msg.sender, withdraw_amount));
        deposit_records[msg.sender] = 0;
    }


}