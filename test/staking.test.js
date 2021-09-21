const { expect } = require("chai");
const hre = require("hardhat");

describe("Staking", function() {
    let GrayblockStakingContract, ProjectTokenContract, TradedTokenContract, accounts;

    before(async function () {
        const accounts = await hre.ethers.getSigners();

        const ProjectToken = await hre.ethers.getContractFactory("Token");
        ProjectTokenContract = await ProjectToken.deploy();

        const TradedToken = await hre.ethers.getContractFactory("Token");
        TradedTokenContract = await TradedToken.deploy();

        const IterableMapping = await hre.ethers.getContractFactory("IterableMapping");
        const IterableMappingContract = await IterableMapping.deploy();

        const GrayblockStaking = await hre.ethers.getContractFactory(
            "GrayblockStaking",
            {
                libraries: {
                    IterableMapping: IterableMappingContract.address
                }
            }
        );

        //console.log(GrayblockStaking);

        GrayblockStakingContract = await GrayblockStaking.deploy(TradedTokenContract.address, ProjectTokenContract.address, accounts[0].address);
    })

    it("staking is working", async () => {
        // await GrayblockStakingContract.stake(
        //     100,
        //     {from: accounts[0].address}
        // )
    })
});
