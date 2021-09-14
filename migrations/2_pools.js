const Pools = artifacts.require("./Pools");

module.exports = function (deployer) {
  deployer.deploy(Pools);
};
