// import { toNano } from '@ton/core';
// import { Staker } from '../wrappers/Staker';
// import { NetworkProvider } from '@ton/blueprint';

// export async function run(provider: NetworkProvider) {
//     const staker = provider.open(await Staker.fromInit());

//     await staker.send(
//         provider.sender(),
//         {
//             value: toNano('0.05'),
//         },
//         {
//             $$type: 'Deploy',
//             queryId: 0n,
//         }
//     );

//     await provider.waitForDeploy(staker.address);

//     // run methods on `staker`
// }
