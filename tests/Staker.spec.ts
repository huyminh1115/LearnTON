// import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
// import { toNano } from '@ton/core';
// import { Staker } from '../wrappers/Staker';
// import '@ton/test-utils';

// describe('Staker', () => {
//     let blockchain: Blockchain;
//     let deployer: SandboxContract<TreasuryContract>;
//     let staker: SandboxContract<Staker>;

//     beforeEach(async () => {
//         blockchain = await Blockchain.create();

//         staker = blockchain.openContract(await Staker.fromInit());

//         deployer = await blockchain.treasury('deployer');

//         const deployResult = await staker.send(
//             deployer.getSender(),
//             {
//                 value: toNano('0.05'),
//             },
//             {
//                 $$type: 'Deploy',
//                 queryId: 0n,
//             }
//         );

//         expect(deployResult.transactions).toHaveTransaction({
//             from: deployer.address,
//             to: staker.address,
//             deploy: true,
//             success: true,
//         });
//     });

//     it('should deploy', async () => {
//         // the check is done inside beforeEach
//         // blockchain and staker are ready to use
//     });
// });
