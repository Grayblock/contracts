const ProjectToken = artifacts.require("./ProjectToken");

module.exports = function (deployer) {
  // if(deployer.network_id === 5777){
  deployer.deploy(ProjectToken);
  // }
  // return;
};
