import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { StakingJetton } from '../wrappers/StakingJetton';
import '@ton/test-utils';

describe('StakingJetton', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let stakingJetton: SandboxContract<StakingJetton>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        stakingJetton = blockchain.openContract(await StakingJetton.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await stakingJetton.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: stakingJetton.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and stakingJetton are ready to use
    });
});
