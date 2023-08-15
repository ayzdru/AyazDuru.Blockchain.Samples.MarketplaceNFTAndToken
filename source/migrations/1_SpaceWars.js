const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const SpaceWarsToken = artifacts.require('SpaceWarsToken');
const SpaceWarsNFT = artifacts.require('SpaceWarsNFT');
const SpaceWarsMultiwrap = artifacts.require('SpaceWarsMultiwrap');
const SpaceWarsPack = artifacts.require('SpaceWarsPack');
const SpaceWarsMarketplace = artifacts.require("SpaceWarsMarketplace");
const SpaceWarsGame = artifacts.require('SpaceWarsGame');
var nativeTokenWrapperAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

module.exports = async function (deployer, network, accounts) {

  var account = accounts[0];  
  console.log('Account: ', account);

  const spaceWarsTokenInstance = await deployProxy(SpaceWarsToken, [account, "SpaceWarsToken", "SWT", "https://metadata-url.com/my-metadata",[], account, account, 0], { deployer, initializer: 'initialize', unsafeAllowCustomTypes : true, unsafeAllow: ['delegatecall'] });
  const spaceWarsToken = await SpaceWarsToken.deployed();
  console.log('SpaceWarsToken Deployed', spaceWarsTokenInstance.address); 

  const spaceWarsNFTInstance = await deployProxy(SpaceWarsNFT, [account, "SpaceWarsNFT", "SWNFT", "https://metadata-url.com/my-metadata",[], account, account, 0,0, account], { deployer, initializer: 'initialize', unsafeAllowCustomTypes : true, unsafeAllow: ['delegatecall'] });
  const spaceWarsNFT = await SpaceWarsNFT.deployed();
  console.log('SpaceWarsNFT Deployed', spaceWarsNFTInstance.address);

  const spaceWarsMultiwrapInstance = await deployProxy(SpaceWarsMultiwrap, ["SpaceWarsMultiwrap", "SWM","https://metadata-url.com/my-metadata",[], account, 0, nativeTokenWrapperAddress], { deployer, initializer: 'initialize', unsafeAllowCustomTypes : true, unsafeAllow: ['delegatecall'] });
  const spaceWarsMultiwrap = await SpaceWarsMultiwrap.deployed();
  console.log('SpaceWarsMultiwrap Deployed', spaceWarsMultiwrapInstance.address); 

  const spaceWarsPackInstance = await deployProxy(SpaceWarsPack, ["SpaceWarsPack", "SWP","https://metadata-url.com/my-metadata",[], account, 0, nativeTokenWrapperAddress], { deployer, initializer: 'initialize', unsafeAllowCustomTypes : true, unsafeAllow: ['delegatecall'] });
  const spaceWarsPack = await SpaceWarsPack.deployed();
  console.log('SpaceWarsPack Deployed', spaceWarsPackInstance.address); 

  const spaceWarsMarketplaceInstance = await deployProxy(SpaceWarsMarketplace, ["https://metadata-url.com/my-metadata", [],[spaceWarsNFTInstance.address, spaceWarsMultiwrapInstance.address, spaceWarsPackInstance.address], account, 0, nativeTokenWrapperAddress], { deployer, initializer: 'initialize', unsafeAllowCustomTypes : true, unsafeAllow: ['delegatecall'] });
  const spaceWarsMarketplace = await SpaceWarsMarketplace.deployed();  
  console.log('SpaceWarsMarketplace Deployed', spaceWarsMarketplaceInstance.address);

  const spaceWarsGameInstance = await deployProxy(SpaceWarsGame, [spaceWarsTokenInstance.address, spaceWarsNFTInstance.address, spaceWarsPackInstance.address], { deployer, initializer: 'initialize', unsafeAllowCustomTypes : true, unsafeAllow: ['delegatecall'] });
  const spaceWarsGame = await SpaceWarsGame.deployed();
  console.log('SpaceWarsGame Deployed', spaceWarsGameInstance.address); 
};