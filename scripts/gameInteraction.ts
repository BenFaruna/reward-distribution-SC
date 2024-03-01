import { ethers } from "hardhat";

// - RewardToken deployed to 0xe0BEefc6bA741Ae8e93c3b637cf0325668C98814
// - RewardDistributor deployed to 0x892b9Ba85dCfa6145872727e20155C83E511821e
// - RewardGame deployed to 0x18A31270f8c13f5fe171Eb5ab141Ea4Ecb8D4e9C

const main = async () => {
  const [deployer, other] = await ethers.getSigners();
  const gameAddress = "0x18A31270f8c13f5fe171Eb5ab141Ea4Ecb8D4e9C";
  // const rewardDistributor = "0x892b9Ba85dCfa6145872727e20155C83E511821e";

  const gameContract = await ethers.getContractAt("RewardGame", gameAddress);
  // const rewardContract = await ethers.getContractAt("RewardsDistribution", rewardDistributor);

  // (await rewardContract.connect(deployer).changeEntryToDistribution(3)).wait();


  // this should only be called once
  // const registerTx = await rewardContract.connect(other).registerUser();
  // registerTx.wait();

  const flipTx = await gameContract.connect(other).flip(false);
  flipTx.wait();

  const correctFlip = await gameContract.connect(other).userWins(other.address);
  console.log(`User wins: ${correctFlip}`)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});