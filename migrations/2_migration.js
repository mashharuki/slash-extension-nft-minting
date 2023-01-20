const ERC721Demo = artifacts.require("ERC721Demo");

module.exports = function (deployer) {
  deployer.deploy(ERC721Demo);
};