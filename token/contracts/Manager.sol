pragma solidity ^0.6.0;

import "./Token.sol";
import "./test88MPH.sol";
import "./SafeMath.sol";
import "./updateState.sol";
import "evm-contracts/src/v0.6/ChainlinkClient.sol";
import "evm-contracts/src/v0.6/vendor/Ownable.sol";


contract Manager is ChainlinkClient, Ownable {
    
    uint256 constant private ORACLE_PAYMENT = 1 * LINK;
    
    address payable admin;
    Token public AtokenContract;
    Token public BtokenContract;
    Token public stableCoin;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    uint256 public state;
    test88MPH public test88MPH_contract;
    //raw amount of Stablecoin Interest earned
    uint256 public interestEarned;
    // the extra % in interest that users will receive upon redemption
    uint256 public interestMultiplier;
    
    mapping(bytes32 => address payable) public redeem_book;
    

    event Sell(address _buyer, uint256 _amount);

    event RequestStateFulfilled(
    bytes32 indexed requestId,
    uint256 indexed state
  );

    constructor(Token _AtokenContract, Token _BtokenContract, Token _stableCoin, test88MPH _test88MPH_contract , uint256 _tokenPrice, uint256 _state) public Ownable() {
        setPublicChainlinkToken();
        admin = msg.sender;
        AtokenContract = _AtokenContract;
        BtokenContract = _BtokenContract;
        test88MPH_contract = _test88MPH_contract;
        stableCoin = _stableCoin;
        tokenPrice = _tokenPrice;
        state = _state; // leaves open possibility of initializing with wrong state
    }


    /**
        @notice Users can buy an equal amount of A and B tokens
        @param _numberOfTokens The number of A and B tokens requested
    */

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(state == 0);
        //Check to make sure that buyer has allowed stablecoin transfer
        uint _allowance = stableCoin.allowance(msg.sender, address(this));
        //make sure value matches tokens requested
        require(_allowance == SafeMath.mul(_numberOfTokens, tokenPrice));
        require(stableCoin.transferFrom(msg.sender, address(this), _allowance));
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
    */

    function redeem() public payable {
        
        if (state == 0){
            
            bytes32 _cur_request_id = requestState(address(0x4712020cA7E184C545FD2483696c9dC36cb7c36a),"ca0d86424890466f856de3e868087f81");
            redeem_book[_cur_request_id] = msg.sender; 

        } else {
            redeemExecute(msg.sender);
        }
    
    }


    function redeemExecute(address payable redeem_address) internal {

        // redeems Token A if state==1
        if (state == 1){
            uint _tokens_to_redeem = AtokenContract.balanceOf(redeem_address);
            uint _payout_amount = SafeMath.mul(SafeMath.mul(_tokens_to_redeem, tokenPrice), interestMultiplier);
            require(stableCoin.balanceOf(address(this)) >= _payout_amount);
            require(AtokenContract.adminTransfer(redeem_address, address(this), _tokens_to_redeem));
            require(stableCoin.transfer(redeem_address, _payout_amount));
            
        } 
        // redeems Token B if state == 2
        else if (state == 2){
            uint _tokens_to_redeem = BtokenContract.balanceOf(redeem_address);
            uint _payout_amount = SafeMath.mul(SafeMath.mul(_tokens_to_redeem, tokenPrice), interestMultiplier);
            require(stableCoin.balanceOf(address(this))>=_payout_amount);
            require(BtokenContract.adminTransfer(redeem_address, address(this), _tokens_to_redeem));
            require(stableCoin.transfer(redeem_address, _payout_amount));
            
        } 
        // skips redemption if contract is still active
        else { // state=0 
            require(false, "contract still active");
        }
    }


    // ChainLink

    function requestState(address _oracle, string memory _jobId)
        public returns (bytes32 requestId)
        // onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillState.selector);
        req.add("get", "https://i1ihiyjpu8.execute-api.us-west-1.amazonaws.com/default/test_api");
        req.add("path", "state");
        
        // Returns ID of request
        return sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillState(bytes32 _requestId, uint256 _state)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestStateFulfilled(_requestId, _state);
        
        //add state change functionality
        if (state != _state) {
            //initiate earlyWithdraw with funding params
            uint256 depositID = 41;
            uint256 fundingID = 41;
            test88MPH_contract.earlyWithdraw(depositID, fundingID);

            //calculate total interest earned
            interestEarned = SafeMath.sub(stableCoin.balanceOf(address(this)), SafeMath.mul(AtokenContract.totalSupply(), tokenPrice));
            interestMultiplier = SafeMath.div(SafeMath.mul(interestEarned,100), stableCoin.balanceOf(address(this)));
        }
        
        state = _state;
        
        // Load redeem request
        address payable _redeem_address = redeem_book[_requestId];
        redeemExecute(_redeem_address);
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

    function admin88mphDeposit(uint256 amount, uint256 maturationTimestamp) external {
            require(admin == msg.sender);
            //approve payment in stablecoin to 88MPH contract
            stableCoin.approve(address(test88MPH_contract), amount);
            //deposit
            test88MPH_contract.deposit(amount, maturationTimestamp);
            
        }
    

    function admin88mphWithdraw(uint256 depositID, uint256 fundingID) external {
            require(admin == msg.sender);
            test88MPH_contract.withdraw(depositID, fundingID);
        }

}