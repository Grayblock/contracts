const { expect } = require("chai");
const hre = require("hardhat");

describe("Staking", function() {
    before(async function () {
        const accounts = await ethers.getSigners();
        const GrayblockStaking = await hre.ethers.getContractFactory("GrayblockStaking");
        const GrayblockStakingContract = await GrayblockStaking.deploy(accounts[0].address);

        console.log(GrayblockStakingContract);
    })
});
