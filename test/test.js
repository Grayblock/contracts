const { expect } = require("chai");
const hre = require("hardhat");

//const photoNFT= await PhotoNFT.attach(PHOTO_NFT);

describe("Grayblock", function() {
 

 it("tests IDO contract", async function() { 
  const accounts = await ethers.getSigners();
  const Factory = await hre.ethers.getContractFactory("PancakeFactory");
  const factory = await Factory.deploy(accounts[0].address);
  await factory.deployed();
  console.log("factory deployed to:", factory.address);

  const TokenWBNB = await hre.ethers.getContractFactory("Token");
  const tokenWBNB = await TokenWBNB.deploy();
  await tokenWBNB.deployed();
  console.log("TokenWBNB deployed to:", tokenWBNB.address);

  const Router = await hre.ethers.getContractFactory("PancakeRouter");
  const router = await Router.deploy(factory.address,tokenWBNB.address);
  await router.deployed();
  console.log("router contract deployed to:", router.address);

  const Token = await hre.ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Token1 deployed to:", token.address);
  balance=await token.balanceOf(accounts[0].address)
  console.log("accounts[0].address balance of project token before transfer is : ", balance.toNumber())

  const Token2 = await hre.ethers.getContractFactory("Token");
  const token2 = await Token2.deploy();
  await token2.deployed();
  console.log("Token2 deployed to:", token2.address);

  owner=accounts[0].address
  rewardsAddress=token2.address
  const Staking = await hre.ethers.getContractFactory("GrayblockStaking");
  const staking = await Staking.deploy(owner,rewardsAddress,token.address);
  await staking.deployed();
  console.log("Staking contract deployed to:", staking.address);

  projectToken=token.address;
  tradedToken=rewardsAddress;
  const Ido = await hre.ethers.getContractFactory("IDO");
  const ido = await Ido.deploy(projectToken,tradedToken);
  await ido.deployed();
  console.log("IDO contract deployed to:", ido.address);
    
  //test transfer to IDO contract
    console.log("IDO balance of project token before transfer is : ",await token.balanceOf(ido.address) )
    await token.approve(ido.address,8000,{from:accounts[0].address});
    await token.transfer(ido.address,8000,{from:accounts[0].address});
    console.log("IDO balance of project token after transfer is : ",await token.balanceOf(ido.address) )
    expect(await token.balanceOf(ido.address)).to.equal(8000); 

    //test setting functions of IDO contract
    ido.setSale(true,{from:accounts[0].address});
    console.log("sale status is: ",await ido.saleStatus());
    expect(await ido.saleStatus()).to.equal(true);
    ido.setRatio(2,{from:accounts[0].address});
    console.log("ratio is: ",await ido.getRatio());
    expect(await ido.getRatio()).to.equal(2);

    //test buying of tokens in IDO contract
    balance=await token.balanceOf(accounts[0].address)
    balance2=await token2.balanceOf(accounts[0].address)
    console.log("accounts[0].address balance of project token before buy is : ", balance.toNumber())
    console.log("accounts[0].address balance of traded token before buy is : ", balance2.toNumber())
    await token2.approve(ido.address,1000,{from:accounts[0].address});
    ido.buy(1000,{from:accounts[0].address});
    balance=await token.balanceOf(accounts[0].address)
    balance2=await token2.balanceOf(accounts[0].address)
    console.log("accounts[0].address balance of traded token after buy is : ", balance2.toNumber())
    expect(balance2.toNumber()).to.equal(899000); 
    //account 0 gave 8000 and after buying he recieved 2000 with a ratio of 2
    expect(balance.toNumber()).to.equal(894000); 
  });
  it("tests Staking contract", async function() { 
    const accounts = await ethers.getSigners();
    const Factory = await hre.ethers.getContractFactory("PancakeFactory");
    const factory = await Factory.deploy(accounts[0].address);
    await factory.deployed();
    console.log("factory deployed to:", factory.address);
  
    const TokenWBNB = await hre.ethers.getContractFactory("Token");
    const tokenWBNB = await TokenWBNB.deploy();
    await tokenWBNB.deployed();
    console.log("TokenWBNB deployed to:", tokenWBNB.address);

    const Router = await hre.ethers.getContractFactory("PancakeRouter");
    const router = await Router.deploy(factory.address,tokenWBNB.address);
    await router.deployed();
    console.log("router contract deployed to:", router.address);

    const Token = await hre.ethers.getContractFactory("Token");
    const token = await Token.deploy();
    await token.deployed();
    console.log("Token1 deployed to:", token.address);
    balance=await token.balanceOf(accounts[0].address)
    console.log("accounts[0].address balance of project token before transfer is : ", balance.toNumber())

    const Token2 = await hre.ethers.getContractFactory("Token");
    const token2 = await Token2.deploy();
    await token2.deployed();
    console.log("Token2 deployed to:", token2.address);

    owner=accounts[0].address
    rewardsAddress=token2.address
    const Staking = await hre.ethers.getContractFactory("GrayblockStaking");
    const staking = await Staking.deploy(owner,rewardsAddress,token.address);
    await staking.deployed();
    console.log("Staking contract deployed to:", staking.address);

    projectToken=token.address;
    tradedToken=rewardsAddress;
    const Ido = await hre.ethers.getContractFactory("IDO");
    const ido = await Ido.deploy(projectToken,tradedToken);
    await ido.deployed();
    console.log("IDO contract deployed to:", ido.address);

  //test set reward rate
  await staking.setRewardRate(1000,10,{from:accounts[0].address});
  expect(await staking.getRewardRate()).to.equal(100); 

  //test transfer of tokens
  await token2.approve(staking.address,8000,{from:accounts[0].address});
  await token2.transfer(staking.address,8000,{from:accounts[0].address});
  balance=await token2.balanceOf(staking.address)
  console.log("Staking balance of traded token after transfer is : ",balance.toNumber())
  expect(balance.toNumber()).to.equal(8000); 
   //test transfer of tokens
  await staking.notifyRewardAmount(8000,{from:accounts[0].address});
  await token.transfer(accounts[1].address,8000,{from:accounts[0].address});
  balance=await token.balanceOf(accounts[1].address);
  console.log("account 1 balance of project token after before is : ",balance.toNumber())
  expect(balance.toNumber()).to.equal(8000); 

   //test staking + that fee is 1%
  balance=await token.balanceOf(staking.address)
  console.log("Staking balance of project token before staking is : ",balance.toNumber())
  await token.connect(accounts[1]).approve(staking.address,1000,{from:accounts[1].address});
  await staking.connect(accounts[1]).stake(1000,{from:accounts[1].address})
  let fee= await staking.getLastFee();
  expect(fee).to.equal(10); 
  balance=await token.balanceOf(accounts[1].address);
  console.log("account 1 balance of project token after staking is : ",balance.toNumber())
  expect(balance.toNumber()).to.equal(7000); 
    //test balance of contract after staking
  balance=await token.balanceOf(staking.address)
  console.log("Staking balance of project token after staking is : ",balance.toNumber())
  expect(balance.toNumber()).to.equal(990); 
  //test withdraw
  await staking.connect(accounts[1]).withdraw(900,{from:accounts[1].address})
  balance=await token.balanceOf(staking.address)
  console.log("Staking balance of project token after withdraw is : ",balance.toNumber())
  expect(balance.toNumber()).to.equal(90); 

  //test failed withdraw
  await staking.setMinimumTime(10,{from:accounts[0].address});
  try {
    var result = await staking.connect(accounts[1]).withdraw(50,{from:accounts[1].address});
    // The line will only be hit if no error is thrown above!
    throw new Error(`Expected an error and didn't get one!`)
  } catch(err) {
    var expected = `VM Exception while processing transaction: reverted with reason string 'Need to wait minimum time before withdraw'`;
    expect(err.message).to.equal(expected); 
  }
});

 
});
