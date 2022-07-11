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
verifyContract('0x41cB0988Aa0278eDbCf97D4964Dfdd58E4dB5c74')
