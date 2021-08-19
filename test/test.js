const { expect } = require("chai");
const hre = require("hardhat");

//const photoNFT= await PhotoNFT.attach(PHOTO_NFT);

describe("Grayblock", function() {
  it("Tests contracts", async function() {
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
    
    console.log("IDO balance of project token before transfer is : ",await token.balanceOf(ido.address) )
    await token.approve(ido.address,8000,{from:accounts[0].address});
    await token.transfer(ido.address,8000,{from:accounts[0].address});
    ido.setSale(true,{from:accounts[0].address});
    console.log("sale status is: ",await ido.saleStatus());
    ido.setRatio(2,{from:accounts[0].address});
    console.log("ratio is: ",await ido.getRatio());
    console.log("IDO balance of project token after transfer is : ",await token.balanceOf(ido.address) )

    balance=await token.balanceOf(accounts[0].address)
    balance2=await token2.balanceOf(accounts[0].address)

    console.log("accounts[0].address balance of project token before buy is : ", balance.toNumber())
    console.log("accounts[0].address balance of traded token before buy is : ", balance2.toNumber())
    await token2.approve(ido.address,1000,{from:accounts[0].address});
    ido.buy(1000,{from:accounts[0].address});
    balance=await token.balanceOf(accounts[0].address)
    balance2=await token2.balanceOf(accounts[0].address)
    console.log("accounts[0].address balance of project token after buy is : ", )
    console.log("accounts[0].address balance of traded token after buy is : ", balance2.toNumber())

    await token2.approve(staking.address,8000,{from:accounts[0].address});
    await token2.transfer(staking.address,8000,{from:accounts[0].address});
    balance=await token2.balanceOf(staking.address)
    console.log("Staking balance of traded token after transfer is : ",balance.toNumber())
    await token.transfer(accounts[1].address,8000,{from:accounts[0].address});
    balance=await token.balanceOf(accounts[1].address)
    console.log("account 1 balance of project token after transfer is : ",balance.toNumber())
    staking.connect(accounts[1]).stake(1000,{from:accounts[1].address})
    balance=await token2.balanceOf(staking.address)
    console.log("Staking balance of project token after transfer is : ",balance.toNumber())


  });

 
});
