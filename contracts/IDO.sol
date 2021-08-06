// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @author yonatan martsiano
 * @title Initial decentralized coin Offerring(IDO) contract
 */
contract IDO is Ownable {
    uint256 private _startTimeEpoch;
    ERC20 projectToken;
    ERC20 tradeToken;
    uint ratio;
    uint cap;
    bool sale;
    address owner;
    constructor(address _projectToken,address _tradeToken) {
         projectToken=ERC20(_projectToken);
         tradeToken=ERC20(_tradeToken);
         owner=msg.sender;
         cap=0;
         sale=false;
    }
    /**
     * @dev function to buy project token
     */
    function buy(uint amount) public payable returns (bool success) {
        require(sale,"The project token IDO has not started yet");
        require(tradeToken.balanceOf(msg.sender)>= amount && amount != 0 , "The sender does not have the requested trade tokens to send");
        if(cap!=0){
            require(amount<cap,"There is a limit for each user to buy and this amount is over the limit");
        }
        tradeToken.transferFrom(msg.sender,address(this),amount);
        uint256 givenAmount = amount * ratio;
        require(projectToken.balanceOf(address(this))>=givenAmount,"There are not project tokens left in the required amount to give");
        projectToken.transfer( msg.sender, givenAmount);
        return true;
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

       function setSale(bool _sale) public onlyOwner {
        sale=_sale;
       
    }
       function setCap(uint _cap) public onlyOwner returns (bool) {
        cap=_cap;
        return true;
    }
}