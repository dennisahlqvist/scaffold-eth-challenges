// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  uint public deadline;
  uint256 public constant threshold = 1 ether;
  mapping ( address => uint256 ) public balances;
  
  bool public stakingOpen = true;
  bool public openForWithdraw = false;
  
  event Stake(address,uint256);




  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 72 hours;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(block.timestamp<=deadline);

    balances[msg.sender]+=msg.value;
    emit Stake(msg.sender,msg.value);
  }
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public {
    require(stakingOpen);
    stakingOpen = false;
    if(address(this).balance>=threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }else{
      openForWithdraw=true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
    function withdraw() public {
      require(openForWithdraw,"Call execute() first" );
      uint balanceToSend = balances[msg.sender];
      balances[msg.sender] = 0;
      payable(msg.sender).transfer(balanceToSend);
    }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256){
    if(block.timestamp >= deadline){
      return uint(0);
    }else{
      return uint(block.timestamp-deadline);
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()

    receive() external payable {
      stake();
    }




}
