import { ethers } from "hardhat";

async function main() {

  const [deployer] = await ethers.getSigners();

  const userBeforeDistribution = 10;
  const subscriptionId = process.env.SUBSCRIPTION_ID;
  const rewardAmount = ethers.parseUnits("100000", 18);
  

  const rewardToken = await ethers.deployContract("RewardToken");
  await rewardToken.waitForDeployment();

  const rewardDistributor = await ethers.deployContract("RewardDistributor", [rewardToken.target,
    userBeforeDistribution, subscriptionId]);

  await rewardDistributor.waitForDeployment();

  const rewardGame = await ethers.deployContract("RewardGame", [rewardDistributor.target]);
  await rewardGame.waitForDeployment();


  const transferTx = await rewardToken.connect(deployer).transfer(rewardDistributor.target, rewardAmount);
  transferTx.wait();

  const setRewardGameTx = await rewardDistributor.connect(deployer).setGameAddress(rewardGame.target);
  setRewardGameTx.wait();

  const setRewardAmountTx = await rewardDistributor.connect(deployer).changeTotalReward(rewardAmount);
  setRewardAmountTx.wait();

  console.log(
    `RewardToken deployed to ${rewardToken.target}\n
    RewardDistributor deployed to ${rewardDistributor.target}\n
    RewardGame deployed to ${rewardGame.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
