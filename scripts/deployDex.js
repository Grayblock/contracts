// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers } = require("hardhat");
const hre = require("hardhat");
const WBNBaddress="0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const accounts = await ethers.getSigners();
  const Factory = await hre.ethers.getContractFactory("PancakeFactory");
  const factory = await Factory.deploy(accounts[0].address);
  await factory.deployed();
  console.log("factory deployed to:", factory.address);

  const Router = await hre.ethers.getContractFactory("PancakeRouter");
  const router = await Router.deploy(factory.address,WBNBaddress);
  await router.deployed();
  console.log("router contract deployed to:", router.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
