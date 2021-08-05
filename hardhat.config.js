require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-ganache");

var url = 'https://bsc-dataseed.binance.org/'


const BSC_PRIVATE_KEY = "";
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  node: { // Options passed directly to Ganache client
    fork: 'https://bsc-dataseed.binance.org/'
  },
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545"
      
    },
    hardhat: {
      accounts:{
        accountsBalance:"100000000000000000000000000000000",
      },
      gasPrice: 260000,
      gasLimit: 100000000000000000
    },
    BSCtestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,

    },
    BSCmainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 20000000000,
      forking: {
          url: "https://bsc-dataseed.binance.org/",
      }, 
    },
    ganache: {
      url: url,
      gasLimit: 6000000000,
      defaultBalanceEther: 1000000,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {   
          optimizer: {
          enabled: true,
          runs: 1000,
        },},
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      }
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout:12000
  }
};


