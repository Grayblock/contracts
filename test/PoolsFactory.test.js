const { ethers } = require("hardhat");
const { expect } = require("chai");
const { expectEvent } = require("@openzeppelin/test-helpers");

describe("PoolsFactory", () => {
  let poolsFactory;
  let mockTBUSD;
  let owner, alice, bob;

  const name = "Trade Token";
  const symbol = "TBUSD";
  const poolName = "Vietnam power project";

  beforeEach(async () => {
    [owner, alice, bob] = await ethers.getSigners();
    const MockTBUSD = await ethers.getContractFactory("MockToken");
    mockTBUSD = await MockTBUSD.deploy(name, symbol);
    await mockTBUSD.deployed();

    const PoolsFactory = await ethers.getContractFactory("PoolsFactory");
    poolsFactory = await PoolsFactory.deploy(mockTBUSD.address, owner.address);
    await poolsFactory.deployed();

    // console.log(poolsFactory.address, mockTBUSD.address);
  });

  it("should deploy pool and project token", async () => {});
});
