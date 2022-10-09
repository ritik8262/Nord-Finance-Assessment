const { ethers } = require("hardhat");

require("dotenv").config();

VRF_COORDINATOR = process.env.VRF_COORDINATOR;
KEY_HASH = process.env.KEY_HASH;
SUBSCRIPTION_ID = process.env.SUBSCRIPTION_ID;
MAX_GAS = process.env.MAX_GAS;
async function main() {
  const {} = await hre.ethers.getSigners();
  const gameFactory = await hre.ethers.getContractFactory("Game");
  const game = await gameFactory.deploy(
    VRF_COORDINATOR,
    KEY_HASH,
    SUBSCRIPTION_ID,
    MAX_GAS
  );
  await game.deployed();

  console.log("Contract deloyed to:", game.address);

  const initialize = await game.initialize(3);
  await initialize.wait(1);
  console.log("Contract Initialized by the owner");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .then(() => {
    process.exit(0);
  });
