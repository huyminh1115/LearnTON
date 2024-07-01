import { Address, toNano } from '@ton/core';
import { Staking } from '../wrappers/Staking';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const staking = provider.open(
        Staking.fromAddress(Address.parse('EQAHz6oM5wQZL4om-n9MmQt_kkPTgQcb29BX8FNxrA12mnyu')),
    );

    const rewardPerSecond = toNano('10000');
    const endTime = 19184413050n;

    await staking.send(
        provider.sender(),
        {
            value: toNano('0.1'), // reward for staking
        },
        {
            $$type: 'Setting',
            rewardPerSecond,
            endTime,
        },
    );
}
