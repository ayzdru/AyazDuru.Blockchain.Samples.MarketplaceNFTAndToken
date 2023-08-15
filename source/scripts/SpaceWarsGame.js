const SpaceWarsGame = artifacts.require("SpaceWarsGame");
const SpaceWarsPack = artifacts.require("SpaceWarsPack");
const SpaceWarsNFT = artifacts.require("SpaceWarsNFT");
module.exports =  async (callback) => {
  try {
    const spaceWarsGame = await SpaceWarsGame.deployed();
    const spaceWarsPack = await SpaceWarsPack.deployed();
    const spaceWarsNFT = await SpaceWarsNFT.deployed();

    await spaceWarsNFT.setApprovalForAll(spaceWarsGame.address,true);
    await spaceWarsPack.setApprovalForAll(spaceWarsGame.address,true);
    
    console.log(`SpaceWarsGame Contract Address: ${spaceWarsGame.address}`);
    console.log(`SpaceWarsPack Contract Address: ${spaceWarsPack.address}`);
    var accounts = await web3.eth.getAccounts();
    var to = accounts[0];
    console.log(`Account Address: ${to}`);

    var toolPackBalance = await spaceWarsPack.balanceOf(to, 0);
    if(toolPackBalance> 0)
    {
       await spaceWarsPack.safeTransferFrom(to, spaceWarsGame.address,0, toolPackBalance, "0x0");
       console.log(toolPackBalance + " Tool packs transferred.")
    }
    var buildingPackBalance = await spaceWarsPack.balanceOf(to, 1);
    if(buildingPackBalance> 0)
    {
       await spaceWarsPack.safeTransferFrom(to, spaceWarsGame.address,1, buildingPackBalance, "0x0");
       console.log(buildingPackBalance + " Building packs transferred.")
    }
    var robotPackBalance = await spaceWarsPack.balanceOf(to, 2);
    if(robotPackBalance> 0)
    {
       await spaceWarsPack.safeTransferFrom(to, spaceWarsGame.address,2, robotPackBalance, "0x0");
       console.log(robotPackBalance + " Robot packs transferred.")
    }    
    var spaceshipPackBalance = await spaceWarsPack.balanceOf(to, 3);
    if(spaceshipPackBalance > 0)
    {
       await spaceWarsPack.safeTransferFrom(to, spaceWarsGame.address,3, spaceshipPackBalance, "0x0");
       console.log(spaceshipPackBalance + " Spaceship packs transferred.")
    }
//TOOL
    await spaceWarsGame.setTool({
      tokenURI: "ipfs://QmUNvPC6BK16ddN11AYaUf7K8KJCbKbQr2QTURsWqbjZJM",
      rarity: 1,
      resourceType: 1,
      maximumDurability: 250,
      energyConsumed: 10,
      durabilityConsumed: 5,
      maximumWorkerRobotCount: 3,
      power: 10
    });

    await spaceWarsGame.addNFTType("ipfs://QmUNvPC6BK16ddN11AYaUf7K8KJCbKbQr2QTURsWqbjZJM", 1);

    await spaceWarsGame.setCrafConfig(1, {
      packId: 0,
      resources: [{
        resourceType: 0,
        balance: 10
      }]
    });

    //BUILDING

    await spaceWarsGame.setBuilding({
      tokenURI: "ipfs://QmPbbVq19avHyKdAu2VsDLS7hXcsKDhNNZFqXt9jxrcfvG",
      rarity: 1,
      buildingType: 0,
      upgradePrice: 1,
      requiredUpgrades: 5,
      maximumWorkerRobotCount : 2,
      chargeTime : 10,
      maximumDurability: 250,
      rewardResources: [{resourceType: 0, balance : 10}],
      requiredResources: [{resourceType: 1, balance : 5}]
    });

    await spaceWarsGame.addNFTType("ipfs://QmPbbVq19avHyKdAu2VsDLS7hXcsKDhNNZFqXt9jxrcfvG", 3);

    await spaceWarsGame.setCrafConfig(3, {
      packId: 1,
      resources: [{
        resourceType: 0,
        balance: 10
      }]
    });

    //WORKER ROBOT

    await spaceWarsGame.setRobot({ 
      tokenURI: "ipfs://QmYQ1pDCk99vebz9YJj134DkGdCJ1bCbTUrbgF2uhu6Vif",
      rarity: 1,
      robotType: 0,
      power: 10,
      maximumHealth: 100,
      maximumDurability: 200,
      energyConsumed: 5,
      durabilityConsumed: 5
    });
    await spaceWarsGame.addNFTType("ipfs://QmYQ1pDCk99vebz9YJj134DkGdCJ1bCbTUrbgF2uhu6Vif", 4);

    await spaceWarsGame.setRobot({ 
      tokenURI: "ipfs://Qmad3bJiFdmeH3WYn9ZAcnp1vQsiti3Fc8VXeiEc1ZooVu",
      rarity: 2,
      robotType: 0,
      power: 20,
      maximumHealth: 110,
      maximumDurability: 250,
      energyConsumed: 4,
      durabilityConsumed: 4
    });
    await spaceWarsGame.addNFTType("ipfs://Qmad3bJiFdmeH3WYn9ZAcnp1vQsiti3Fc8VXeiEc1ZooVu", 4);

    await spaceWarsGame.setRobot({ 
      tokenURI: "ipfs://QmagFft6XuaajsnPn2negX3xkE6t51SGnaDAKRrnV9XQjt",
      rarity: 3,
      robotType: 0,
      power: 30,
      maximumHealth: 120,
      maximumDurability: 260,
      energyConsumed: 3,
      durabilityConsumed: 3
    });
    await spaceWarsGame.addNFTType("ipfs://QmagFft6XuaajsnPn2negX3xkE6t51SGnaDAKRrnV9XQjt", 4);


    await spaceWarsGame.setRobot({ 
      tokenURI: "ipfs://QmefhSNRMBZeJhRyMcvZUr1eH67nFHHTJesoCAiDLBVu7L",
      rarity: 4,
      robotType: 0,
      power: 40,
      maximumHealth: 130,
      maximumDurability: 280,
      energyConsumed: 2,
      durabilityConsumed: 2
    });
    await spaceWarsGame.addNFTType("ipfs://QmefhSNRMBZeJhRyMcvZUr1eH67nFHHTJesoCAiDLBVu7L", 4);


    await spaceWarsGame.setRobot({ 
      tokenURI: "ipfs://QmPny4WH3kAmHDo1DGiKBwMipuKmv4ZFKBmzLqzNzVyezy",
      rarity: 5,
      robotType: 0,
      power: 50,
      maximumHealth: 150,
      maximumDurability: 300,
      energyConsumed: 1,
      durabilityConsumed: 1
    });
    await spaceWarsGame.addNFTType("ipfs://QmPny4WH3kAmHDo1DGiKBwMipuKmv4ZFKBmzLqzNzVyezy", 4);
//SOLDIER ROBOT

await spaceWarsGame.setRobot({ 
   tokenURI: "ipfs://QmP2XgPjTDwgw3MZYMZAE7RFGy6mbUBf75cyNf7hCyQgsb",
   rarity: 1,
   robotType: 1,
   power: 10,
   maximumHealth: 100,
   maximumDurability: 200,
   energyConsumed: 5,
   durabilityConsumed: 5
 });
 await spaceWarsGame.addNFTType("ipfs://QmP2XgPjTDwgw3MZYMZAE7RFGy6mbUBf75cyNf7hCyQgsb", 4);

 await spaceWarsGame.setRobot({ 
   tokenURI: "ipfs://QmZR1KzW8fs8dKaCZeR4ytWn9RDScVhB2sbV3zJRsVMcWi",
   rarity: 2,
   robotType: 1,
   power: 20,
   maximumHealth: 110,
   maximumDurability: 250,
   energyConsumed: 4,
   durabilityConsumed: 4
 });
 await spaceWarsGame.addNFTType("ipfs://QmZR1KzW8fs8dKaCZeR4ytWn9RDScVhB2sbV3zJRsVMcWi", 4);

 await spaceWarsGame.setRobot({ 
   tokenURI: "ipfs://QmPGAdm1gVGmEGTX1s3dagbiGj2ps7pbDBtzp9FtyHKvn4",
   rarity: 3,
   robotType: 1,
   power: 30,
   maximumHealth: 120,
   maximumDurability: 260,
   energyConsumed: 3,
   durabilityConsumed: 3
 });
 await spaceWarsGame.addNFTType("ipfs://QmPGAdm1gVGmEGTX1s3dagbiGj2ps7pbDBtzp9FtyHKvn4", 4);

 await spaceWarsGame.setRobot({ 
   tokenURI: "ipfs://QmNV1iSRWtes78MFXCBLj4v1P2ar4Nam59UQs8SiceMQtT",
   rarity: 4,
   robotType: 1,
   power: 40,
   maximumHealth: 130,
   maximumDurability: 280,
   energyConsumed: 2,
   durabilityConsumed: 2
 });
 await spaceWarsGame.addNFTType("ipfs://QmNV1iSRWtes78MFXCBLj4v1P2ar4Nam59UQs8SiceMQtT", 4);

 await spaceWarsGame.setRobot({ 
   tokenURI: "ipfs://QmQULmfkkhicdZac8v8vLQLLCsZkQfCKra64Acmm1TSgFD",
   rarity: 5,
   robotType: 1,
   power: 50,
   maximumHealth: 150,
   maximumDurability: 300,
   energyConsumed: 1,
   durabilityConsumed: 1
 });
 await spaceWarsGame.addNFTType("ipfs://QmQULmfkkhicdZac8v8vLQLLCsZkQfCKra64Acmm1TSgFD", 4);

 await spaceWarsGame.setCrafConfig(4, {
  packId: 2,
  resources: [{
    resourceType: 0,
    balance: 10
  }]
});
 //SPACESHIP

 await spaceWarsGame.setShip({
   tokenURI: "ipfs://QmQrwKfmw2WT6mDqxEfkJK22eDGB72q4XtAvr111uGnFwB",
   rarity: 1,
   maximumEnergy: 300,
   maximumToolCount: 2,
   maximumSoldierCount: 1,
   maximumDurability: 250,
   speed: 100,
   power: 5
 });
 await spaceWarsGame.addNFTType("ipfs://QmQrwKfmw2WT6mDqxEfkJK22eDGB72q4XtAvr111uGnFwB", 2);


 await spaceWarsGame.setShip({
   tokenURI: "ipfs://QmSBFw2k368uyqswuwUJTck48YGugxBxfTycnEwWmg6TNF",
   rarity: 2,
   maximumEnergy: 320,
   maximumToolCount: 3,
   maximumSoldierCount: 2,
   maximumDurability: 270,
   speed: 120,
   power: 10
 });
 await spaceWarsGame.addNFTType("ipfs://QmSBFw2k368uyqswuwUJTck48YGugxBxfTycnEwWmg6TNF", 2);

 await spaceWarsGame.setShip({
   tokenURI: "ipfs://QmQVbrYaSL3scAhLB327Tgt59PqnsWTPpi4R8QdMsh9iiT",
   rarity: 3,
   maximumEnergy: 340,
   maximumToolCount: 3,
   maximumSoldierCount: 3,
   maximumDurability: 280,
   speed: 140,
   power: 15
 });
 await spaceWarsGame.addNFTType("ipfs://QmQVbrYaSL3scAhLB327Tgt59PqnsWTPpi4R8QdMsh9iiT", 2);

 await spaceWarsGame.setShip({
   tokenURI: "ipfs://QmZghDTMBvkAcJ7jbrra1c92cMSKSKeQZsQLpDDjiSFGpM",
   rarity: 4,
   maximumEnergy: 360,
   maximumToolCount: 4,
   maximumSoldierCount: 4,
   maximumDurability: 300,
   speed: 160,
   power: 20
 });
 await spaceWarsGame.addNFTType("ipfs://QmZghDTMBvkAcJ7jbrra1c92cMSKSKeQZsQLpDDjiSFGpM", 2);

 await spaceWarsGame.setShip({
   tokenURI: "ipfs://QmZYkbFTiBH8xhYWZ89owEJskHNBzCoLBDUa5x8uX9kHRG",
   rarity: 5,
   maximumEnergy: 400,
   maximumToolCount: 5,
   maximumSoldierCount: 5,
   maximumDurability: 400,
   speed: 200,
   power: 30
 });
 await spaceWarsGame.addNFTType("ipfs://QmZYkbFTiBH8xhYWZ89owEJskHNBzCoLBDUa5x8uX9kHRG", 2);

 await spaceWarsGame.setCrafConfig(2, {
  packId: 3,
  resources: [{
    resourceType: 0,
    balance: 10
  }]
});
//LAND
    await spaceWarsGame.addLand({
      tokenId: 17,
      tokenURI: "ipfs://QmTo96uNXb1x9V6RWHUtrh3uiuA8sEvG2SkjyAifMgADpg",
      rarity: 1,
      commission: 1,
      resourceRewardRate: 1,
      tokenRewardRate: 1,
      totalTokenPower: 0,
      totalResourcePower: 0,
      x: 0,
      y: 0
    });

    await spaceWarsGame.addLand({
      tokenId: 18,
      tokenURI: "ipfs://QmTMTY79BRq31zKKaHieUpSLiTzQ8ssodhRVSuUR38TDtS",
      rarity: 2,
      commission: 2,
      resourceRewardRate: 2,
      tokenRewardRate: 2,
      totalTokenPower: 0,
      totalResourcePower: 0,
      x: -6,
      y: 8
    });

    await spaceWarsGame.addLand({
      tokenId: 19,
      tokenURI: "ipfs://QmQK7rVaZqjLwj1ooF4mvf2SE6R5MUs2bu4rVt3udGRFza",
      rarity: 3,
      commission: 3,
      resourceRewardRate: 3,
      tokenRewardRate: 3,
      totalTokenPower: 0,
      totalResourcePower: 0,
      x: 12,
      y: -12
    });
    

  } catch(err) {
    console.log('Oops: ', err.message);
  }
  callback();
}
