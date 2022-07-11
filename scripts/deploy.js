"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_1 = require("hardhat");
async function main() {
    const BattleShips = await hardhat_1.ethers.getContractFactory("BattleShips");
    const battleShips = await BattleShips.deploy();
    await battleShips.deployed();
    console.log("BattleShips", battleShips.address);
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
