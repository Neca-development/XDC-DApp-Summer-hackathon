import hre from "hardhat";

export async function verifyContract(address: string, ...constructorArguments: any) {
    console.log('Wait a minute for changes to propagate to Etherscan\'s backend...');
    // await waitAMinute();
    console.log('Verifying contract...');
    await hre.run('verify:verify', {
        address,
        constructorArguments: [...constructorArguments],
    });
    console.log('Contract verified on Etherscan :белая_галочка:');
}


// export function waitAMinute() {
//     return new Promise(resolve => setTimeout(resolve, 60000));
// }
verifyContract('0x4C6A8aeB2d21C640F8Faaf480368d5c531fd85b9')
