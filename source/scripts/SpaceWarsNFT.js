const SpaceWarsNFT = artifacts.require("SpaceWarsNFT")
var ethers = require('ethers');
module.exports =  async (callback) => {
  try {
    const spaceWarsNFT = await SpaceWarsNFT.deployed();
    console.log(`SpaceWarsNFT Contract Address: ${spaceWarsNFT.address}`);
    var accounts = await web3.eth.getAccounts();
    var to = accounts[0];
    console.log(`SpaceWarsNFT Mint Account Address: ${to}`);      

    
    //TOOL 1
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmUNvPC6BK16ddN11AYaUf7K8KJCbKbQr2QTURsWqbjZJM", 4000000);

    //BUILDING 1
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmPbbVq19avHyKdAu2VsDLS7hXcsKDhNNZFqXt9jxrcfvG", 4000000);
    
    //WORKER ROBOT 1
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmYQ1pDCk99vebz9YJj134DkGdCJ1bCbTUrbgF2uhu6Vif", 4000000);
    //WORKER ROBOT 2
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://Qmad3bJiFdmeH3WYn9ZAcnp1vQsiti3Fc8VXeiEc1ZooVu", 3000000);
    //WORKER ROBOT 3
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmagFft6XuaajsnPn2negX3xkE6t51SGnaDAKRrnV9XQjt", 1500000);
    //WORKER ROBOT 4
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmefhSNRMBZeJhRyMcvZUr1eH67nFHHTJesoCAiDLBVu7L", 1000000);
    //WORKER ROBOT 5
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmPny4WH3kAmHDo1DGiKBwMipuKmv4ZFKBmzLqzNzVyezy", 500000);


    //SOLDIER ROBOT 1
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmP2XgPjTDwgw3MZYMZAE7RFGy6mbUBf75cyNf7hCyQgsb", 4000000);
    //SOLDIER ROBOT 2
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmZR1KzW8fs8dKaCZeR4ytWn9RDScVhB2sbV3zJRsVMcWi", 3000000);
    //SOLDIER ROBOT 3
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmPGAdm1gVGmEGTX1s3dagbiGj2ps7pbDBtzp9FtyHKvn4", 1500000);
    //SOLDIER ROBOT 4
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmNV1iSRWtes78MFXCBLj4v1P2ar4Nam59UQs8SiceMQtT", 1000000);
    //SOLDIER ROBOT 5
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmQULmfkkhicdZac8v8vLQLLCsZkQfCKra64Acmm1TSgFD", 500000);
    
    
    //SPACESHIP 1
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmQrwKfmw2WT6mDqxEfkJK22eDGB72q4XtAvr111uGnFwB", 4000000);
    //SPACESHIP 2
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmSBFw2k368uyqswuwUJTck48YGugxBxfTycnEwWmg6TNF", 3000000);
    //SPACESHIP 3
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmQVbrYaSL3scAhLB327Tgt59PqnsWTPpi4R8QdMsh9iiT", 1500000);
    //SPACESHIP 4
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmZghDTMBvkAcJ7jbrra1c92cMSKSKeQZsQLpDDjiSFGpM", 1000000);
    //SPACESHIP 5
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmZYkbFTiBH8xhYWZ89owEJskHNBzCoLBDUa5x8uX9kHRG", 500000);  


    //LAND 1
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmTo96uNXb1x9V6RWHUtrh3uiuA8sEvG2SkjyAifMgADpg", 1);
    //LAND 2
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmTMTY79BRq31zKKaHieUpSLiTzQ8ssodhRVSuUR38TDtS", 1);
    //LAND 3
    await spaceWarsNFT.mintTo(to, ethers.constants.MaxUint256, "ipfs://QmQK7rVaZqjLwj1ooF4mvf2SE6R5MUs2bu4rVt3udGRFza", 1);


  } catch(err) {
    console.log('Oops: ', err.message);
  }
  callback();
}
