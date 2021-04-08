pragma solidity ^0.6.12;


import "evm-contracts/src/v0.6/ChainlinkClient.sol";
import "evm-contracts/src/v0.6/vendor/Ownable.sol";


contract updateState is ChainlinkClient, Ownable {
  uint256 constant private ORACLE_PAYMENT = 1 * LINK;
  uint256 public State;

  event RequestStateFulfilled(
    bytes32 indexed requestId,
    uint256 indexed state
  );

  constructor() public Ownable() {
    setPublicChainlinkToken();
  }

  function requestState(address _oracle, string memory _jobId)
    public
    onlyOwner
    returns (uint256)
  {
    Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.fulfillState.selector);
    req.add("get", "https://i1ihiyjpu8.execute-api.us-west-1.amazonaws.com/default/test_api");
    req.add("path", "state");
    sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    return State;
  }

  function fulfillState(bytes32 _requestId, uint256 _state)
    public
    recordChainlinkFulfillment(_requestId)
  {
    emit RequestStateFulfilled(_requestId, _state);
    State = _state;
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
