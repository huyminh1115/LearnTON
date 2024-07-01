import { Address, toNano } from '@ton/core';
import { Staking } from '../wrappers/Staking';
import { Staker } from '../wrappers/Staker';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const stakerContract = provider.open(
        Staker.fromAddress(Address.parse('kQBYFM7aGG6EvmeGLt1HsX_vqEjP1SHZc5UUcOA1o506MLNK')),
    );

    const stakerData = await stakerContract.getStakerData();
    console.log('Staker data: ', stakerData);
}
