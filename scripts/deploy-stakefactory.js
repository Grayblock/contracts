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

  const StakeFactory = await hre.ethers.getContractFactory("StakingFactory", {
    libraries: {
      IterableMapping: iterableMapping.address,
    },
  });

  const stakeFactory = await StakeFactory.deploy(
    process.env.FEE_COLLECTOR,
    process.env.TRADE_TOKEN
  );
  await stakeFactory.deployed();
  console.log("stakeFactory deployed to:", stakeFactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
