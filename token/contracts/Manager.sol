pragma solidity ^0.6.0;

import "./Token.sol";

contract Manager {
    address payable admin;
    Token public AtokenContract;
    Token public BtokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    uint256 public state;
    string public test;

    event Sell(address _buyer, uint256 _amount);

    constructor(Token _AtokenContract, Token _BtokenContract, uint256 _tokenPrice, uint256 _state) public {
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
        require(state == 0);
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(AtokenContract.mint(msg.sender, _numberOfTokens));
        require(BtokenContract.mint(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        Sell(msg.sender, _numberOfTokens);
    }

    function trigger_active() public {
        require(msg.sender==admin); 
        state = 0;
    }

    function trigger_triggered() public {
        require(msg.sender==admin);
        state = 1;
    }

    function trigger_timeout() public {
        require(msg.sender==admin);
        state = 2;
    }

    function redeem(Token _token, uint256 _numberOfTokens) public payable {
        
        if (state == 1){
            require(address(_token)==address(AtokenContract), "This coin has no worth");
            require(AtokenContract.balanceOf(msg.sender)>=_numberOfTokens);
            // tranfer from user to this contract
            require(AtokenContract.adminTransfer(msg.sender, address(this), _numberOfTokens));
            msg.sender.transfer(multiply(_numberOfTokens,tokenPrice));
            test="A";
        } else if (state == 2){
            require(address(_token)==address(BtokenContract), "This coin has no worth");
            require(BtokenContract.balanceOf(msg.sender)>=_numberOfTokens);
            // tranfer from user to this contract
            require(BtokenContract.adminTransfer(msg.sender, address(this), _numberOfTokens));
            msg.sender.transfer(multiply(_numberOfTokens,tokenPrice));
            test="B";
        } else { // state=0 
            require(false, "contract still active");
        }
        
    }
}