import { toNano } from '@ton/core';
import { StakingJetton } from '../wrappers/StakingJetton';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const stakingJetton = provider.open(await StakingJetton.fromInit());

    await stakingJetton.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(stakingJetton.address);

    // run methods on `stakingJetton`
}
