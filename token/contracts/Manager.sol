pragma solidity ^0.6.0;

import "./Token.sol";

contract ShrubManager {
    address payable admin;
    Token public AtokenContract;
    Token public BtokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    string public state;

    event Sell(address _buyer, uint256 _amount);

    constructor(Token _AtokenContract, Token _BtokenContract, uint256 _tokenPrice, string memory _state) public {
        admin = msg.sender;
        AtokenContract = _AtokenContract;
        BtokenContract = _BtokenContract;
        tokenPrice = _tokenPrice;
        state = _state; // leaves open possibility of initializing with wrong state
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(AtokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(BtokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(AtokenContract.transfer(msg.sender, _numberOfTokens));
        require(BtokenContract.transfer(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        Sell(msg.sender, _numberOfTokens);
    }

    function trigger_active() public {
        require(msg.sender==admin); 
        state = "active";
    }

    function trigger_triggered() public {
        require(msg.sender==admin);
        state = "triggered";
    }

    function trigger_timeout() public {
        require(msg.sender==admin);
        state = "timeout";
    }

    function endSale() public {
        require(msg.sender == admin);
        require(AtokenContract.transfer(admin, AtokenContract.balanceOf(address(this))));
        require(BtokenContract.transfer(admin, BtokenContract.balanceOf(address(this))));

        // UPDATE: Let's not destroy the contract here
        // Just transfer the balance to the admin
        admin.transfer(address(this).balance);
    }
}