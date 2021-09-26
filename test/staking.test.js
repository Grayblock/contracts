const { expect } = require("chai");
const hre = require("hardhat");

describe("Staking", function() {
    let GrayblockStakingContract, ProjectTokenContract, TradedTokenContract, accounts;

    before(async function () {
        accounts = await hre.ethers.getSigners();

        const ProjectToken = await hre.ethers.getContractFactory("Token");
        ProjectTokenContract = await ProjectToken.deploy();

        const TradedToken = await hre.ethers.getContractFactory("Token");
        TradedTokenContract = await TradedToken.deploy();

        const IterableMapping = await hre.ethers.getContractFactory("IterableMapping");
        const IterableMappingContract = await IterableMapping.deploy();

        const GrayblockStaking = await hre.ethers.getContractFactory(
            "GrayblockStakingMock",
            {
                libraries: {
                    IterableMapping: IterableMappingContract.address
                }
            }
        );

        GrayblockStakingContract = await GrayblockStaking.deploy(TradedTokenContract.address, ProjectTokenContract.address, accounts[5].address);
    })
    it("energy developers put traded token into staking pool", async () => {
        await TradedTokenContract.approve(GrayblockStakingContract.address, 100);
        await GrayblockStakingContract.putTradedToken(100);
    })
    it("staking is not working with insuffient balance", async () => {
        let thrownError;
        try {
            await GrayblockStakingContract.connect(accounts[1]).stake(100);
        } catch (error) {
            thrownError = error;
        }

        expect(thrownError.message).to.include('insufficient balance');
    })
    it("staking is not working without approval", async () => {
        let thrownError;
        try {
            await GrayblockStakingContract.connect(accounts[0]).stake(100);
        } catch (error) {
            thrownError = error;
        }

        expect(thrownError.message).to.include('ERC20: transfer amount exceeds allowance');
    })
    it("staking is working", async () => {
        const p1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const p2 = await ProjectTokenContract.balanceOf(accounts[0].address);
        const p3 = await ProjectTokenContract.balanceOf(accounts[5].address);

        await ProjectTokenContract.approve(GrayblockStakingContract.address, 100);
        await GrayblockStakingContract.stake(100)

        const c1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const c2 = await ProjectTokenContract.balanceOf(accounts[0].address);
        const c3 = await ProjectTokenContract.balanceOf(accounts[5].address);

        expect(c1.sub(p1).toString()).to.equal('99');
        expect(p2.sub(c2).toString()).to.equal('100');
        expect(c3.sub(p3).toString()).to.equal('1');
    })
    it("staking is working", async () => {
        await ProjectTokenContract.transfer(accounts[1].address, 100);

        const p1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const p2 = await ProjectTokenContract.balanceOf(accounts[1].address);
        const p3 = await ProjectTokenContract.balanceOf(accounts[5].address);

        await ProjectTokenContract.connect(accounts[1]).approve(GrayblockStakingContract.address, 100);
        await GrayblockStakingContract.connect(accounts[1]).stake(100)

        const c1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const c2 = await ProjectTokenContract.balanceOf(accounts[1].address);
        const c3 = await ProjectTokenContract.balanceOf(accounts[5].address);

        expect(c1.sub(p1).toString()).to.equal('99');
        expect(p2.sub(c2).toString()).to.equal('100');
        expect(c3.sub(p3).toString()).to.equal('1');
    })
    it("update allocation", async () => {
        await GrayblockStakingContract.updateAllocation(50);
    })
    it("claiming reward is working", async () => {
        const p1 = await TradedTokenContract.balanceOf(accounts[0].address);

        await GrayblockStakingContract.connect(accounts[0]).claimReward();

        const c1 = await TradedTokenContract.balanceOf(accounts[0].address);

        expect(c1.sub(p1).toString()).to.equal('25');
    })
    it("unstaking is not working during lock time", async () => {
        let thrownError;
        try {
            await GrayblockStakingContract.unStake(99)
        } catch (error) {
            thrownError = error;
        }

        expect(thrownError.message).to.include('can not unstake during lock time');
    })
    it("unstaking is not working with exceed amount", async () => {
        let thrownError;
        try {
            await GrayblockStakingContract.unStake(100)
        } catch (error) {
            thrownError = error;
        }

        expect(thrownError.message).to.include('insufficient balance');
    })
    it("unstaking is working", async () => {
        const p1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const p2 = await ProjectTokenContract.balanceOf(accounts[0].address);

        await GrayblockStakingContract.setBlockTimeStamp('1816922014');
        await GrayblockStakingContract.unStake(99)

        const c1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const c2 = await ProjectTokenContract.balanceOf(accounts[0].address);

        expect(p1.sub(c1).toString()).to.equal('99');
        expect(c2.sub(p2).toString()).to.equal('99');
    })
    it("update allocation", async () => {
        await GrayblockStakingContract.updateAllocation(50);
    })
    it("claiming reward is working", async () => {
        const p1 = await TradedTokenContract.balanceOf(accounts[1].address);

        await GrayblockStakingContract.connect(accounts[1]).claimReward();

        const c1 = await TradedTokenContract.balanceOf(accounts[1].address);

        expect(c1.sub(p1).toString()).to.equal('75');
    })
    it("unstaking is working", async () => {
        const p1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const p2 = await ProjectTokenContract.balanceOf(accounts[1].address);

        await GrayblockStakingContract.setBlockTimeStamp('1816922014');
        await GrayblockStakingContract.connect(accounts[1]).unStake(99)

        const c1 = await ProjectTokenContract.balanceOf(GrayblockStakingContract.address);
        const c2 = await ProjectTokenContract.balanceOf(accounts[1].address);

        expect(p1.sub(c1).toString()).to.equal('99');
        expect(c2.sub(p2).toString()).to.equal('99');
    })
    it("Gas testing", async () => {
        console.log(accounts.length);
        await TradedTokenContract.approve(GrayblockStakingContract.address, 100);
        await GrayblockStakingContract.putTradedToken(100);

        for(let i = 1; i <= 19; i++) {
            await ProjectTokenContract.transfer(accounts[i].address, 100);
            await ProjectTokenContract.connect(accounts[i]).approve(GrayblockStakingContract.address, 100);
            await GrayblockStakingContract.connect(accounts[i]).stake(100)
        }

        const receipt = await GrayblockStakingContract.estimateGas.updateAllocation(50);

        console.log(receipt.toString());

        console.log(await hre.ethers.accounts.create());

        //console.log(receipt.gasLimit.toString() * receipt.gasPrice.toString())
    })
});
