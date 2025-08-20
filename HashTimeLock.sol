// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
contract HashTimeLock {
    address payable public owner; 
    address payable public receiver;

    constructor(address _receiver_address) {
        owner = payable(msg.sender); 
        hash ="";
        receiver = payable(_receiver_address);  
    }
    modifier isReceiver() {
        require(msg.sender == receiver, "Caller is not receiver");
        _;
    }
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    string public key;
    bytes32 public hash;
    uint256 public deadline;
    uint256 public deposited;
    
    // Function to return  
    // current balance of owner 
    function getBalance() public view returns(uint256){ 
        address contractAddress = address(this);
        return contractAddress.balance; 
    } 
    function startSwap(bytes32 _hash) payable public returns(string memory){
		require(msg.value != 0, "Incorrect amount");
		require(hash == "", "Swap already started");       
		hash = _hash;
		deadline = block.timestamp + 86400;// 1 day;          
        deposited = msg.value;
        return string(abi.encodePacked("Swap started with ",receiver));
    }
   function withdraw(string calldata _key) isReceiver() public payable returns(string memory) {
        require(deadline > block.timestamp, "Missed Deadline");
		require(bytes(_key).length <= 32, "Failed length check");
        require(hash ==sha256(abi.encodePacked(_key)), "Failed hash check");
		
		
        key = _key;
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = receiver.call{value: getBalance()}("");
        require(sent, "Failed to send Ether");
        return string(abi.encodePacked("Ok",data));
    }
    function refund() isOwner() public payable returns(string memory){
         require(deadline < block.timestamp, "Waiting for deadline");
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = owner.call{value: deposited}("");
        require(sent, "Failed to send Ether");
        return string(abi.encodePacked("Ok",data));
    }

}

Change the COMPILER to the value 0.8.7+commit.e28d00a7.
Change the EVM VERSION to the value london.
