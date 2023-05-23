
const hre = require("hardhat");

async function main() {

  // We get the contract to deploy
  const RefiSureDAONft = await hre.ethers.getContractFactory("RefiSureDAONft");
  const refisuredaonft = await RefiSureDAONft.deploy();

  await refisuredaonft.deployed();

  console.log("RefiSureDAONft deployed to:", greeter.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
