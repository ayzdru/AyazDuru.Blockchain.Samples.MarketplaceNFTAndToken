const SpaceWarsToken = artifacts.require("SpaceWarsToken")
module.exports =  async (callback) => {
  try {
    const spaceWarsToken = await SpaceWarsToken.deployed();
    console.log(`SpaceWarsToken Contract Address: ${spaceWarsToken.address}`);
    var accounts = await web3.eth.getAccounts();
    var to = accounts[0];
    console.log(`SpaceWarsToken Mint Account Address: ${to}`);
    var decimals = await spaceWarsToken.decimals();
    var decimalsZeros = "";
    for (let index = 0; index < decimals; index++) {
      decimalsZeros += "0";      
    }
    await spaceWarsToken.mintTo(to, "100000000" + decimalsZeros);
    console.log("Minted: "+  (await spaceWarsToken.balanceOf(to)).toString());

  } catch(err) {
    console.log('Oops: ', err.message);
  }
  callback();
}
