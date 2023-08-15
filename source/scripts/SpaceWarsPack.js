const SpaceWarsPack = artifacts.require("SpaceWarsPack");
const SpaceWarsNFT = artifacts.require("SpaceWarsNFT")
module.exports =  async (callback) => {
  try 
  {
    const spaceWarsPack = await SpaceWarsPack.deployed();
    console.log(`SpaceWarsPack Contract Address: ${spaceWarsPack.address}`);
    const spaceWarsNFT = await SpaceWarsNFT.deployed();
    await spaceWarsNFT.setApprovalForAll(spaceWarsPack.address,true);
    var accounts = await web3.eth.getAccounts();
    var to = accounts[0];
    console.log(`Account Address: ${to}`);
    
   var toolPack = await spaceWarsPack.createPack([{
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 0,
      totalAmount: 4000000
    }],[4000000], "ipfs://Qmau3yb8sYy8jF8W7KiqFAxrwgmM55TXWn7ed32SSZkHZw", Math.floor(Date.now() / 1000), 1, to);

    var buildingPack = await spaceWarsPack.createPack([{
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 1,
      totalAmount: 4000000
    }],[4000000], "ipfs://QmRQceq7rJDnkKJ5FK1zGS9Zczcqgsc535b38rXYpA8tLE", Math.floor(Date.now() / 1000), 1, to);


   var robotPack = await spaceWarsPack.createPack([{
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 2,
      totalAmount: 4000000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 3,
      totalAmount: 3000000
    }
    ,
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 4,
      totalAmount: 1500000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 5,
      totalAmount: 1000000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 6,
      totalAmount: 500000
    },{
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 7,
      totalAmount: 4000000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 8,
      totalAmount: 3000000
    }
    ,
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 9,
      totalAmount: 1500000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 10,
      totalAmount: 1000000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 11,
      totalAmount: 500000
    }],[4000000,3000000,1500000, 1000000, 500000, 4000000,3000000,1500000, 1000000, 500000], "ipfs://QmfGiYYaLhWpyjvEUpEYNaPuUY21ojRCcTsrNf9EwcC1tc", Math.floor(Date.now() / 1000), 1, to);


    var spaceshipPack = await spaceWarsPack.createPack([{
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 12,
      totalAmount: 4000000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 13,
      totalAmount: 3000000
    }
    ,
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 14,
      totalAmount: 1500000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 15,
      totalAmount: 1000000
    },
    {
      assetContract:   spaceWarsNFT.address,
      tokenType: 2,
      tokenId: 16,
      totalAmount: 500000
    }],[4000000,3000000,1500000, 1000000, 500000], "ipfs://QmU9wtkDSAcVP78gGLfw6FYvcYJ5rKTVViwAKPZ7WGQYpi", Math.floor(Date.now() / 1000), 1, to);


    await spaceWarsPack.openPack(0, 5);
    await spaceWarsPack.openPack(1, 5);
    await spaceWarsPack.openPack(2, 10);
    await spaceWarsPack.openPack(3, 10);


    var toolBalance =  await spaceWarsNFT.balanceOf(to, 0);

    console.log("Tool balance: " + toolBalance);

    //console.log(pack);
    //var packId = (await spaceWarsPack.nextTokenIdToMint()) - 1;
    //var balance = await spaceWarsPack.balanceOf(to, packId);
    //console.log(`Account Pack Id: ${packId}`);
    //console.log(`Account Balance: ${balance}`);
  }
  catch(err) {
    console.log('Oops: ', err.message);
  }
  callback();
}