import { toNano } from '@ton/core';
import { StakerJetton } from '../wrappers/StakerJetton';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const stakerJetton = provider.open(await StakerJetton.fromInit());

    await stakerJetton.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(stakerJetton.address);

    // run methods on `stakerJetton`
}
