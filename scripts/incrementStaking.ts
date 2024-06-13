// import { Address, toNano } from '@ton/core';
// import { Staking } from '../wrappers/Staking';
// import { NetworkProvider, sleep } from '@ton/blueprint';

// export async function run(provider: NetworkProvider, args: string[]) {
//     const ui = provider.ui();

//     const address = Address.parse(args.length > 0 ? args[0] : await ui.input('Staking address'));

//     if (!(await provider.isContractDeployed(address))) {
//         ui.write(`Error: Contract at address ${address} is not deployed!`);
//         return;
//     }

//     const staking = provider.open(Staking.fromAddress(address));

//     const counterBefore = await staking.getCounter();

//     await staking.send(
//         provider.sender(),
//         {
//             value: toNano('0.05'),
//         },
//         {
//             $$type: 'Add',
//             queryId: 0n,
//             amount: 1n,
//         }
//     );

//     ui.write('Waiting for counter to increase...');

//     let counterAfter = await staking.getCounter();
//     let attempt = 1;
//     while (counterAfter === counterBefore) {
//         ui.setActionPrompt(`Attempt ${attempt}`);
//         await sleep(2000);
//         counterAfter = await staking.getCounter();
//         attempt++;
//     }

//     ui.clearActionPrompt();
//     ui.write('Counter increased successfully!');
// }
