// import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config({ path: ".env" });

const ALCHEMY_MAINNET_API_KEY_URL = process.env.ALCHEMY_MAINNET_API_KEY_URL;

const ALCHEMY_SEPOLIA_API_KEY_URL = process.env.ALCHEMY_SEPOLIA_API_KEY_URL;

const ALCHEMY_MUMBAI_API_KEY_URL = process.env.ALCHEMY_MUMBAI_API_KEY_URL;

const ACCOUNT_PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY;

const ACCOUNT_PRIVATE_KEY_2 = process.env.ACCOUNT_PRIVATE_KEY_2;

module.exports = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      forking: {
        url: ALCHEMY_MAINNET_API_KEY_URL,
      },
    },
    sepolia: {
      url: ALCHEMY_SEPOLIA_API_KEY_URL,
      accounts: [ACCOUNT_PRIVATE_KEY, ACCOUNT_PRIVATE_KEY_2],
    },
    mumbai: {
      url: ALCHEMY_MUMBAI_API_KEY_URL,
      accounts: [ACCOUNT_PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};