// import { toNano } from '@ton/core';
// import { Staking } from '../wrappers/Staking';
// import { NetworkProvider } from '@ton/blueprint';

// export async function run(provider: NetworkProvider) {
//     const staking = provider.open(await Staking.fromInit(BigInt(Math.floor(Math.random() * 10000))));

//     await staking.send(
//         provider.sender(),
//         {
//             value: toNano('0.05'),
//         },
//         {
//             $$type: 'Deploy',
//             queryId: 0n,
//         }
//     );

//     await provider.waitForDeploy(staking.address);

//     console.log('ID', await staking.getId());
// }
