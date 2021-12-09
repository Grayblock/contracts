// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

require("dotenv").config();
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const FactoryLib = await hre.ethers.getContractFactory("Factory");
  const factoryLib = await FactoryLib.deploy();
  await factoryLib.deployed();
  console.log("Lib Factory deployed to:", factoryLib.address);

  const PoolsFactory = await hre.ethers.getContractFactory("PoolsFactory", {
    libraries: {
      Factory: factoryLib.address,
    },
  });
  const poolsFactory = await PoolsFactory.deploy(
    process.env.TRADE_TOKEN,
    process.env.ADMIN
  );
  await poolsFactory.deployed();
  console.log("PoolsFactory deployed to:", poolsFactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
