const TradeToken = artifacts.require("./TradeToken");

module.exports = function (deployer) {
  // if(deployer.network_id === 5777){
  deployer.deploy(TradeToken);
  // }
  // return;
};
