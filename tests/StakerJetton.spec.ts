import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { StakerJetton } from '../wrappers/StakerJetton';
import '@ton/test-utils';

describe('StakerJetton', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let stakerJetton: SandboxContract<StakerJetton>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        stakerJetton = blockchain.openContract(await StakerJetton.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await stakerJetton.send(
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
            to: stakerJetton.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and stakerJetton are ready to use
    });
});
