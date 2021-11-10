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

  // We get the contract to deploy
  const tradeToken = await deployToken("Trade Token", "TBUSD");
  console.log("Trade token deployed to:", tradeToken);

  const projectToken = await deployToken("Project Token", "TGVS");
  console.log("Project token deployed to:", projectToken);

  const Pools = await hre.ethers.getContractFactory("Pools");
  const pools = await Pools.deploy(projectToken, tradeToken);
  await pools.deployed();
  console.log("Pools deployed to:", pools.address);

  const IterableMapping = await hre.ethers.getContractFactory(
    "IterableMapping"
  );
  const iterableMapping = await IterableMapping.deploy();
  await iterableMapping.deployed();
  console.log("Lib IterableMapping deployed to:", iterableMapping.address);

  const GrayblockStaking = await hre.ethers.getContractFactory(
    "GrayblockStaking",
    {
      libraries: {
        IterableMapping: iterableMapping.address,
      },
    }
  );
  const grayblockStaking = await GrayblockStaking.deploy(
    tradeToken,
    projectToken,
    process.env.FEE_COLLECTOR
  );
  await grayblockStaking.deployed();
  console.log("GrayblockStaking deployed to:", grayblockStaking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

async function deployToken(name, symbol) {
  const Token = await hre.ethers.getContractFactory("Token");
  const token = await Token.deploy(name, symbol);

  await token.deployed();
  return token.address;
}
