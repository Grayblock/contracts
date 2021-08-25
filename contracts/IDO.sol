// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SafeMathUpgradeable.sol";
/**
 * @author yonatan martsiano
 * @title Initial decentralized coin Offerring(IDO) contract
 */
contract IDO is Ownable {
   using SafeMathUpgradeable for uint;
    uint256 private _startTimeEpoch;
    ERC20 projectToken;
    ERC20 tradeToken;
    uint ratio;
    uint cap;
    bool sale;
      uint time;
      uint goal;
      uint totalTokens;
   mapping(address => uint256) private Invested;  

    constructor(address _projectToken,address _tradeToken,uint _goal) {
         projectToken=ERC20(_projectToken);
         tradeToken=ERC20(_tradeToken);
         cap=0;
         sale=false;
         goal=_goal;
    }
    /**
     * @dev function to buy project token
     */
    function buy(uint amount) public payable returns (bool success) {
       require(block.timestamp<time,"the IDO is over");
       require(projectToken.balanceOf(address(this))<goal,"The goal has been reached");
        require(sale,"The project token IDO has not started yet");
        require(tradeToken.balanceOf(msg.sender)>= amount && amount != 0 , "The sender does not have the requested trade tokens to send");
        if(cap!=0){
            require(amount<cap,"There is a limit for each user to buy and this amount is over the limit");
        }
        tradeToken.transferFrom(msg.sender,address(this),amount);
         Invested[msg.sender]=Invested[msg.sender]+amount;
        return true;
    }

       function claim() public payable returns (bool success) {
       require(block.timestamp>time,"the IDO is not over yet");
      if(projectToken.balanceOf(address(this))>goal){
         uint amount = totalTokens.div(goal);
         projectToken.transfer( msg.sender, amount.mul(Invested[msg.sender]));
      }
      if(projectToken.balanceOf(address(this))<goal){
         tradeToken.transfer( msg.sender, Invested[msg.sender]);
      }
       
    }

   
    function returnTokens() public onlyOwner returns (bool) {
        projectToken.transferFrom(address(this), owner(), projectToken.balanceOf(address(this)));
        return true;
    }
    function withdrawTokens() public onlyOwner returns (bool) {
        tradeToken.transferFrom(address(this), owner(), projectToken.balanceOf(address(this)));
        return true;
    }
    function tokensLeft() public view returns(uint){
       return projectToken.balanceOf(address(this)) ;
    }
    function saleStatus() public view returns(bool){
   
       return sale ;
    }
    function getOwner() public view returns(address){
       return owner() ;
    }
    function getRatio() public view returns(uint){
       return ratio ;
    }
    function tradedTokens() public view returns(address){
       return address(tradeToken) ;
    }
    function projectTokens() public view returns(address){
       return address(projectToken) ;
    }
   function setRatio(uint _ratio) public onlyOwner returns (bool) {
        ratio=_ratio;
        return true;
    }

       function startSale(uint _time,uint _totalTokens) public onlyOwner {
         time=_time;
         totalTokens=_totalTokens;
        sale=true;
       
    }
       function setCap(uint _cap) public onlyOwner returns (bool) {
        cap=_cap;
        return true;
    }
}