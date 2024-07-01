import { Address, toNano } from '@ton/core';
import { Staking } from '../wrappers/Staking';
import { Staker } from '../wrappers/Staker';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const stakingContract = provider.open(
        Staking.fromAddress(Address.parse('EQAHz6oM5wQZL4om-n9MmQt_kkPTgQcb29BX8FNxrA12mnyu')),
    );

    const systemData = await stakingContract.getSystemData();
    console.log('System data: ', systemData);
}
