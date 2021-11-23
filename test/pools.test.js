// const { ethers } = require("hardhat");
// const { expect } = require("chai");
// const { BigNumber } = require("@ethersproject/bignumber")
// const { BN, time, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')

// describe("Pools", function () {
//     let Pools, pools;
//     let ProjectToken, pToken;
//     let TradeToken, tradeToken;
//     let tx, balance, currentTime;

//     before(async () => {
//         [owner, alice, bob, cindy, david] = await ethers.getSigners();

//         ProjectToken = await ethers.getContractFactory("Token");
//         TradeToken = await ethers.getContractFactory("Token");
//         Pools = await ethers.getContractFactory("Pools");

//         pToken = await ProjectToken.connect(owner).deploy();
//         await pToken.deployed();

//         tradeToken = await TradeToken.connect(owner).deploy();
//         await tradeToken.deployed();

//         pools = await Pools.connect(owner).deploy(pToken.address, tradeToken.address);
//         await pools.deployed();

//         console.log('pToken contract deployed at', pToken.address);
//         console.log('tradeToken contract deployed at', tradeToken.address);
//         console.log('Pools contract deployed at', pools.address);

//     });

//     it("Able to check pToken and tToken in Pools", async () => {
//         let tToken = await pools.tradeToken()
//         let pToken = await pools.projectToken()
//         console.log('tToken', (tToken));
//         console.log('pToken', (pToken));
//     });

//     it("Faucet and Approve Pools Contract", async () => {
//         tx = await pToken.connect(owner).faucet(parseUnits(100));
//         await tx.wait()

//         tx = await pToken.connect(owner).approve(pools.address, parseUnits(100));
//         await tx.wait()

//     });

//     it("Pool Creation Tests by Owner", async () => {
//         currentTime = await time.latest();
//         tx = await pools.connect(owner).CreatePool(parseUnits(100), currentTime.toString(), parseUnits(20), parseUnits(10));
//         await tx.wait()

//         balance = await pToken.balanceOf(pools.address);
//         console.log('pToken of owner ==>', formatUnits(balance));

//     });

//     it("Pool Creation Fail Tests", async () => {

//         await expectRevert(pools.connect(bob).CreatePool(parseUnits(100), currentTime.toString(), parseUnits(20), parseUnits(10)), "Ownable: caller is not the owner");
//         // await expect(pools.connect(bob).CreatePool(parseUnits(10), currentTime.toString(), parseUnits(10), parseUnits(4))).to.be.revertedWith("Ownable: caller is not the owner");
//     });

//     it("Pool Creation Fail Tests by Owner", async () => {

//         await expectRevert(pools.connect(owner).CreatePool(parseUnits(100), currentTime.toString(), parseUnits(101), parseUnits(10)), "Goal cannot be more than TotalTokenAmount");

//     });

//     it("Pool Creation Fail Tests by Owner", async () => {

//         await expectRevert(pools.connect(owner).CreatePool(parseUnits(100), currentTime.toString(), parseUnits(20), parseUnits(21)), "Cap per user cannot be more than goal");

//     });

//     it("Pool Investing Tests by alice ", async () => {
//         tx = await tradeToken.connect(alice).faucet(parseUnits(20));
//         await tx.wait()

//         tx = await tradeToken.connect(alice).approve(pools.address, parseUnits(20));
//         await tx.wait()

//         tx = await pools.connect(alice).Invest(parseUnits(1));
//         await tx.wait()
//     });

//     it("Pool Investing Fail Tests by alice", async () => {
//         tx = await tradeToken.connect(alice).faucet(parseUnits(10));
//         await tx.wait()

//         tx = await tradeToken.connect(alice).approve(pools.address, parseUnits(10));
//         await tx.wait()

//         await expectRevert(pools.connect(alice).Invest(parseUnits(22)), "Pool token Goal has reached");

//     });

//     it("Pool Investing Fail Tests by alice", async () => {
//         tx = await tradeToken.connect(alice).faucet(parseUnits(10));
//         await tx.wait()

//         tx = await tradeToken.connect(alice).approve(pools.address, parseUnits(10));
//         await tx.wait()

//         await expectRevert(pools.connect(alice).Invest(parseUnits(13)), "There is a limit for each user to buy and this amount is over the limit");
//     });
  
//     it("Pool Investing Fail Tests by cindy", async () => {

//         await expectRevert(pools.connect(cindy).Invest(parseUnits(10)), "The sender does not have the requested trade tokens to send");

//     });

//     it("Pool Investing Tests by bob", async () => {
//         tx = await tradeToken.connect(bob).faucet(parseUnits(25));
//         await tx.wait()

//         tx = await tradeToken.connect(bob).approve(pools.address, parseUnits(25));
//         await tx.wait()

//         tx = await pools.connect(bob).Invest(parseUnits(10));
//         await tx.wait()

//     });

//     it("Pool Investing Fail Tests by bob", async () => {
//         tx = await tradeToken.connect(bob).faucet(parseUnits(10));
//         await tx.wait()

//         tx = await tradeToken.connect(bob).approve(pools.address, parseUnits(10));
//         await tx.wait()

//         await expectRevert(pools.connect(bob).Invest(parseUnits(25)), "Pool token Goal has reached");

//     });

//     it("Withdraw Project Tokens Fail Tests by owner", async () => {

//         await expectRevert(pools.connect(owner).withdrawProjectTokens(), "Pool has not ended yet");

//     }); 

//     it("Withdraw Trade Tokens Fail Tests by owner", async () => {

//         await expectRevert(pools.connect(owner).withdrawProjectTokens(), "Pool has not ended yet");

//     });

//     it("Claim Token after Investing Fail Tests by alice ", async () => {

//         await expectRevert(pools.connect(alice).claimTokens(), "Pool has not ended yet");

//     });

//     it("Get Refund after Pool Investing Fail Tests by alice ", async () => {

//         // await increaseTime(7, "days");
//         await expectRevert(pools.connect(alice).getRefund(), "Pool has not ended yet");

//     });
    
//     it("Claim Token Fail after Investing Tests by bob ", async () => {
        
//         // await increaseTime(7, "days");
//         await expectRevert(pools.connect(bob).claimTokens(),"Pool has not ended yet");
     
//         balance = await tradeToken.balanceOf(bob.address);
//         console.log('tradeToken of bob===>', formatUnits(balance));

//         balance = await tradeToken.balanceOf(pools.address);
//         console.log('tradeToken of pools ===>', formatUnits(balance));

//         balance = await pToken.balanceOf(bob.address);
//         console.log('pToken of bob===>', formatUnits(balance));

//     });

//     it("Update Pool Decrease End End Time by owner Test", async () => {

//         endTime = await pools.connect(owner).PoolEndTime()
//         console.log("endTime======>", endTime.toString());

//         currentTime = await time.latest();

//         tx = await pools.connect(owner).updatePoolEndTime(BigNumber.from("1632536851"));
//         await tx.wait()
//         updatedEndTime = await pools.connect(owner).PoolEndTime()
//         console.log("updatedEndTime======>", updatedEndTime.toString());

//     });

//     it("Update Pool Increase End Time by owner Test", async () => {

//         endTime = await pools.connect(owner).PoolEndTime()
//         console.log("endTime======>", endTime.toString());

//         currentTime = await time.latest();

//         tx = await pools.connect(owner).updatePoolEndTime(BigNumber.from("1634990893"));
//         await tx.wait()
//         updatedEndTime = await pools.connect(owner).PoolEndTime()
//         console.log("updatedEndTime======>", updatedEndTime.toString());

//     });

//     it("Investing Tests by alice ", async () => {

//         balance = await tradeToken.balanceOf(pools.address);
//         console.log('tradeToken of pools===> ', formatUnits(balance));

//         tx = await tradeToken.connect(alice).faucet(parseUnits(20));
//         await tx.wait()

//         tx = await tradeToken.connect(alice).approve(pools.address, parseUnits(20));
//         await tx.wait()

//         tx = await pools.connect(alice).Invest(parseUnits(9));
//         await tx.wait()
//     });

//     it("Claim tokens Tests by alice ", async () => {

//         balance = await tradeToken.balanceOf(pools.address);
//         console.log('tradeToken of pools===> ', formatUnits(balance));

//         await increaseTime(2, "months");

//         tx = await pools.connect(alice).claimTokens();
//         await tx.wait()

//         balance = await pToken.balanceOf(alice.address);
//         console.log('ProjectToken of alice===> ', formatUnits(balance));

//     });

//     it("Get Refund after Pool Investing Tests for Reaching Goal by alice ", async () => {

//         await increaseTime(2, "months");
//         await (pools.connect(bob).getRefund(), "Pool successful");

//         balance = await tradeToken.balanceOf(bob.address);
//         console.log('tradeToken of bob -->', formatUnits(balance));
//     });

//     it(" Withdraw Project Tokens Tests by owner", async () => {
 
//         await increaseTime(2, "months");
//         await (pools.connect(owner).withdrawProjectTokens());
        
//         balance = await pToken.balanceOf(pools.address);
//         console.log('pToken of pools===>', formatUnits(balance));
//     });
    
//     it(" Withdraw Trade Tokens Tests by owner", async () => {
        
//         await increaseTime(2, "months");
//         await (pools.connect(owner).withdrawTradeTokens());
        
//         balance = await tradeToken.balanceOf(pools.address);
//         console.log('tradeToken of pools===> ', formatUnits(balance));
//     });

// });

// // Lsit of Helper functions
// // Converts checksum
// const increaseTime = async (amount, type) => {
//     if (type == 'seconds') {
//         await time.increase(amount);
//     } else if (type == 'minutes') {
//         await time.increase(60 * amount);
//     } else if (type == 'hours') {
//         await time.increase(60 * 60 * amount);
//     } else if (type == 'days') {
//         await time.increase(60 * 60 * 24 * amount);
//     } else if (type == 'weeks') {
//         await time.increase(60 * 60 * 24 * 7 * amount);
//     } else if (type == 'months') {
//         await time.increase(60 * 60 * 24 * 30 * amount);
//     } else if (type == 'years') {
//         await time.increase(60 * 60 * 24 * 30 * 12 * amount);
//         // await time.increase(60  60  24 * 7 + 1);
//     }
// }

// const address = (params) => {
//     return ethers.utils.getAddress(params);
// }

// // Converts token units to smallest individual token unit, eg: 1 DAI = 10^18 units 
// const parseUnits = (params) => {
//     return ethers.utils.parseUnits(params.toString(), 0);
// }

// // Converts token units from smallest individual unit to token unit, opposite of parseUnits
// const formatUnits = (params) => {
//     return ethers.utils.formatUnits(params.toString(), 0);
// }

// // Calculate Slippage, default 10 %
// const slippage = (params) => {
//     return params - params * 10 ;
// }
