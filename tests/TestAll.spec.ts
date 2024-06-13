import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Staking } from '../wrappers/Staking';
import '@ton/test-utils';

describe('Staking', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let staker: SandboxContract<TreasuryContract>;
    let staking: SandboxContract<Staking>;

    beforeAll(async () => {
        blockchain = await Blockchain.create();

        staking = blockchain.openContract(await Staking.fromInit(0n));

        deployer = await blockchain.treasury('deployer');
        staker = await blockchain.treasury('staker');

        const deployResult = await staking.send(
            deployer.getSender(),
            {
                value: toNano('100'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: staking.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and staking are ready to use
    });

    // it('should increase counter', async () => {
    //     const increaseTimes = 3;
    //     for (let i = 0; i < increaseTimes; i++) {
    //         console.log(`increase ${i + 1}/${increaseTimes}`);

    //         const increaser = await blockchain.treasury('increaser' + i);

    //         const counterBefore = await staking.getCounter();

    //         console.log('counter before increasing', counterBefore);

    //         const increaseBy = BigInt(Math.floor(Math.random() * 100));

    //         console.log('increasing by', increaseBy);

    //         const increaseResult = await staking.send(
    //             increaser.getSender(),
    //             {
    //                 value: toNano('0.05'),
    //             },
    //             {
    //                 $$type: 'Add',
    //                 queryId: 0n,
    //                 amount: increaseBy,
    //             },
    //         );

    //         expect(increaseResult.transactions).toHaveTransaction({
    //             from: increaser.address,
    //             to: staking.address,
    //             success: true,
    //         });

    //         const counterAfter = await staking.getCounter();

    //         console.log('counter after increasing', counterAfter);

    //         expect(counterAfter).toBe(counterBefore + increaseBy);
    //     }
    // });
});
