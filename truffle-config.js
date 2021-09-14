/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */
const HDWalletProvider = require("@truffle/hdwallet-provider");
//const teamsMnemonic = "enhance scan dose rib lab jelly damage box museum leaf tail retreat";
const mnemonic = "ethics almost stairs news violin pear pulp female among smile exercise silent";

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
    },
    kovan: {
        provider: function() {
          return new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161");
        },
        network_id: '42',
      }
  },
  plugins: ["solidity-coverage"],
  compilers: {
    solc: {
      settings: {
        evmVersion: "byzantium",
        optimizer: { enabled: true, runs: 200 },
      },     
      version: "^0.4.24",
      docker: false,
      parser: "solcjs",
    }
  }
};
