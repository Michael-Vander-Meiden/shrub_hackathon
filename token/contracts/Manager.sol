pragma solidity ^0.6.0;

import "./Token.sol";
import "./SafeMath.sol";
import "./updateState.sol";
import "evm-contracts/src/v0.6/ChainlinkClient.sol";
import "evm-contracts/src/v0.6/vendor/Ownable.sol";


contract Manager is ChainlinkClient, Ownable {
    
    uint256 constant private ORACLE_PAYMENT = 1 * LINK;
    
    address payable admin;
    Token public AtokenContract;
    Token public BtokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    uint256 public state;
    

    event Sell(address _buyer, uint256 _amount);

    event RequestStateFulfilled(
    bytes32 indexed requestId,
    uint256 indexed state
  );

    constructor(Token _AtokenContract, Token _BtokenContract, uint256 _tokenPrice, uint256 _state) public Ownable() {
        setPublicChainlinkToken();
        admin = msg.sender;
        AtokenContract = _AtokenContract;
        BtokenContract = _BtokenContract;
        tokenPrice = _tokenPrice;
        state = _state; // leaves open possibility of initializing with wrong state
    }


    /**
        @notice Users can buy an equal amount of A and B tokens
        @param _numberOfTokens The number of A and B tokens requested
    */

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(state == 0);
        require(msg.value == SafeMath.mul(_numberOfTokens, tokenPrice));
        require(AtokenContract.mint(msg.sender, _numberOfTokens));
        require(BtokenContract.mint(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        Sell(msg.sender, _numberOfTokens);
    }

    /**
        @notice admin can change the contract state to "active"
    */

    function trigger_active() public {
        require(msg.sender==admin); 
        state = 0;
    }

    /**
        @notice admin can change the contract state to "triggered"
    */

    function trigger_triggered() public {
        require(msg.sender==admin);
        state = 1;
    }

    /**
        @notice admin can change the contract state to "timedout"
    */

    function trigger_timeout() public {
        require(msg.sender==admin);
        state = 2;
    }

    /**
        @notice Allows users to exchange either A or B tokens for ETH
        @param _token The type of token being redeemed (must be A or B)
        @param _numberOfTokens The number of A or B tokens to be redeemed 
    */

    function redeem(Token _token, uint256 _numberOfTokens) public payable {
        
        if (state == 0){
            requestState(address(0x4712020cA7E184C545FD2483696c9dC36cb7c36a),"ca0d86424890466f856de3e868087f81");
            redeemExecute(_token, _numberOfTokens);
        } else {
            redeemExecute(_token, _numberOfTokens);
        }
    
    }


    function redeemExecute(Token _token, uint256 _numberOfTokens) internal {

        if (state == 1){
            require(address(_token)==address(AtokenContract), "This coin has no worth");
            require(AtokenContract.balanceOf(msg.sender)>=_numberOfTokens);
            require(address(this).balance>=SafeMath.mul(_numberOfTokens, tokenPrice));
            require(AtokenContract.adminTransfer(msg.sender, address(this), _numberOfTokens));
            msg.sender.transfer(SafeMath.mul(_numberOfTokens,tokenPrice));
            
        } else if (state == 2){
            require(address(_token)==address(BtokenContract), "This coin has no worth");
            require(BtokenContract.balanceOf(msg.sender)>=_numberOfTokens);
            require(address(this).balance>=SafeMath.mul(_numberOfTokens, tokenPrice));
            require(BtokenContract.adminTransfer(msg.sender, address(this), _numberOfTokens));
            msg.sender.transfer(SafeMath.mul(_numberOfTokens,tokenPrice));
            
        } else { // state=0 
            require(false, "contract still active");
        }
    }


    // ChainLink

    function requestState(address _oracle, string memory _jobId)
        public
        onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillState.selector);
        req.add("get", "https://i1ihiyjpu8.execute-api.us-west-1.amazonaws.com/default/test_api");
        req.add("path", "state");
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillState(bytes32 _requestId, uint256 _state)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestStateFulfilled(_requestId, _state);
        state = _state;
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    )
        public
        onlyOwner
    {
        cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
        return 0x0;
        }

        assembly { // solhint-disable-line no-inline-assembly
        result := mload(add(source, 32))
        }
    }

}