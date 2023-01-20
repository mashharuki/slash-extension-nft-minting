const MintExtension = artifacts.require("MintExtension");

module.exports = function (deployer) {
  deployer.deploy(MintExtension);
};