const Pools = artifacts.require("Pools");
const projectToken = artifacts.require("ProjectToken");
const tradeToken = artifacts.require("TradeToken");

// const TestMainToken = artifacts.require("TestMainToken");
const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');
//const timeMachine = require('ganache-time-traveler');
const zero_address = "0x0000000000000000000000000000000000000000";
var BN = web3.utils.BN;

// const rate = new BN('1000000000'); // 1 eth^18 = 1 token^6
const amount = new BN('3000000000000000000'); //3 tokens for sale
// const invest = web3.utils.toWei('0.01', 'ether'); //0.01eth;
const invest = new BN('3000000000000000000');

contract("Pools", async accounts => {
  let instance, Token;

  beforeEach(async () => {
    instance = await Pools.deployed();
    projectToken = await projectToken.deployed();
    tradeToken = await tradeToken.deployed();
  })

  it("give allownce of 121", async () => {
    const allow = 121;
    // let Token = await TestToken.deployed();
    await projectToken.approve(accounts[0], allow, { from: accounts[2] });
    let allownce = await projectToken.allowance(accounts[2], accounts[0]);
    assert.equal(allownce, allow);
  });

  // it("show no pools", async () => {
  //   // let instance = await Pools.deployed();
  //   let mypools = await instance.poolsCount.call();
  //   console.log(mypools);
  //   assert.equal(mypools, 0);
  // });

  it("open a day long pool, check balance", async () => {
    // let instance = await Pools.deployed();
    let projectToken = await projectToken.deployed()
    await projectToken.approve(instance.address, amount, { from: accounts[0] });
    let date = new Date();
    // date.setDate(date.getDate() + 1);   // add a day
    await instance.CreatePool(amount. Math.floor(amount, date.getTime() / 1000) + 60, Math.div(amount, 10), Math.div(amount, 10), { from: accounts[0] });
    let newpools = await instance.poolsCount.call();
    assert.equal(newpools.length, 1, "Got 1 pool");
    let tokensInContract = await projectToken.balanceOf(instance.address);
    console.log(tokensInContract.toString());
    assert.equal(tokensInContract.toString(), amount.toString(), "Got the tokens");
  });

  // it("invest, check balance", async () => {
  //   // let instance = await Pools.deployed();
  //   // let Token = await TestToken.deployed();
  //   await instance.InvestETH(0, { value: invest, from: accounts[1] }); //3-1
  //   let tokensInContract = await Token.balanceOf(instance.address);
  //   assert.equal(tokensInContract.toString(),'2000000'  , "Got the tokens"); //2 left
  // });

  // it("open a day long pool, invest, check creator balance", async () => {
  //   // let instance = await Pools.deployed();
  //   let beforeBalance = await web3.eth.getBalance(accounts[0]);
  //   await instance.InvestETH(0, { value: invest, from: accounts[1] }); //2-1
  //   let afterBalance = await web3.eth.getBalance(accounts[0]);
  //   assert.isAbove(afterBalance - beforeBalance, 0, "Got the eth minus fee");
  //   // let myinvest = await instance.GetMyInvestmentIds({ from: accounts[1] });
  //   // assert.isAbove(myinvest.length, 0);
  // });

  // it("take fee", async () => {
  //   // let instance = await Pools.deployed();
  //   let beforeBalance = await web3.eth.getBalance(instance.address);
  //   assert.notEqual(beforeBalance,0);
  //   await instance.WithdrawETHFee(accounts[0], { from: accounts[0] });
  //   let afterBalance = await web3.eth.getBalance(instance.address);
  //   assert.equal(afterBalance,0);
  // });

  it("check fail attemts, open pool with no allow", async () => {
    // let instance = await Pools.deployed();
    // let Token = await TestToken.deployed();
    let date = new Date();
    date.setDate(date.getDate() + 1);   // add a day
    await truffleAssert.reverts(instance.CreatePool(Token.address, Math.floor(date.getTime() / 1000) + 60, rate, amount, zero_address, 0, { from: accounts[0] }));
  });

  it("Fail invest 0 eth", async () => {
    // let instance = await Pools.deployed();
    await truffleAssert.reverts(instance.InvestETH(0, { value: 0, from: accounts[1] }));
  });

  it("check fail attemts, send ETH to contract", async () => {
    // let instance = await Pools.deployed();
    await truffleAssert.reverts(instance.send(invest, { from: accounts[0] }));
  });

  it("Should allow send ETH", async () => {
    // let instance = await Pools.deployed();
    await instance.SwitchIsPayble({ from: accounts[0] });
    let IsPayble = await instance.IsPayble.call();
    assert.isTrue(IsPayble);
    let startBalance = await web3.eth.getBalance(instance.address);
    await instance.send(amount, { from: accounts[0] });
    let actualBalance = await web3.eth.getBalance(instance.address);
    console.log(actualBalance.toString());
    assert.equal(actualBalance - startBalance, amount);
  });

  it("open pool in a day , check balance", async () => {
    // let instance = await Pools.deployed();
    let Token = await TestToken.deployed()
    await Token.approve(instance.address, amount, { from: accounts[0] });
    let date = new Date();
    date.setDate(date.getDate() + 1);   // add a day
    await instance.CreatePool(Token.address, Math.floor(date.getTime() / 1000) + 60, rate, amount, zero_address, 0, { from: accounts[0] });
    let newpools = await instance.poolsCount.call();
    assert.equal(newpools.toNumber(), 2, "Got 2 pools");
    // let status = await instance.GetPoolStatus(1);
    // assert.equal(status.toNumber(),2);
  });

  // it("open a day long pool, invest", async () => {
  //   instance = await Pools.new();
  //   await Token.approve(instance.address, amount, { from: accounts[0] });
  //   let date = new Date();
  //   date.setDate(date.getDate() + 1);   // add a day
  //   await instance.CreatePool(Token.address, Math.floor(date.getTime() / 1000) + 60, rate, amount, zero_address, 0, { from: accounts[0] });
  //   await instance.InvestETH(0,{ value: invest, from: accounts[0] });
  //   let tokensInContract = await Token.balanceOf(instance.address);
  //   assert.equal(tokensInContract.toString(), "149580000000", "Got the tokens");
  // });

});
