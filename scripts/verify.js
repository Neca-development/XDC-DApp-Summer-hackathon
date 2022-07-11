"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyContract = void 0;
const hardhat_1 = __importDefault(require("hardhat"));
async function verifyContract(address, ...constructorArguments) {
    console.log('Wait a minute for changes to propagate to Etherscan\'s backend...');
    // await waitAMinute();
    console.log('Verifying contract...');
    await hardhat_1.default.run('verify:verify', {
        address,
        constructorArguments: [...constructorArguments],
    });
    console.log('Contract verified on Etherscan :белая_галочка:');
}
exports.verifyContract = verifyContract;
// export function waitAMinute() {
//     return new Promise(resolve => setTimeout(resolve, 60000));
// }
verifyContract('0x4C6A8aeB2d21C640F8Faaf480368d5c531fd85b9');
