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

  const IterableMapping = await hre.ethers.getContractFactory(
    "IterableMapping"
  );
  const iterableMapping = await IterableMapping.deploy();
  await iterableMapping.deployed();
  console.log("Lib IterableMapping deployed to:", iterableMapping.address);

  console.log("Deploying stake pool contract...");
  const Pools = await hre.ethers.getContractFactory("GrayblockStaking", {
    libraries: {
      IterableMapping: iterableMapping.address,
    },
  });

  const pools = await Pools.deploy(
    process.env.TRADE_TOKEN,
    "0x80c1E6220F11E65F65Ec4FDaA828D4824d386747",
    "0xa1c4E23fcA8f2cff13749b9136ff30945ae5203B",
    "0x96e4C543b7e98670d6a083BDA065984Ca567e36F",
    "Test Pool"
  );
  await pools.deployed();
  console.log("Pool deployed to:", pools.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
