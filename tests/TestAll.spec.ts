import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { Staking } from '../wrappers/Staking';
import { Staker } from '../wrappers/Staker';
import '@ton/test-utils';

function sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

describe('Staking', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let staker: SandboxContract<TreasuryContract>;
    let stakingContract: SandboxContract<Staking>;
    let stakerContract: SandboxContract<Staker>;

    beforeAll(async () => {
        blockchain = await Blockchain.create();

        stakingContract = blockchain.openContract(await Staking.fromInit());

        deployer = await blockchain.treasury('deployer');
        staker = await blockchain.treasury('staker');

        const deployResult = await stakingContract.send(
            deployer.getSender(),
            {
                value: toNano('1'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: stakingContract.address,
            deploy: true,
            success: true,
        });
    });

    it('config staking: ', async () => {
        const rewardPerSecond = toNano('1');
        const endTime = 17184413050n;
        const settingResult = await stakingContract.send(
            deployer.getSender(),
            {
                value: toNano('100'), // reward for staking
            },
            {
                $$type: 'Setting',
                rewardPerSecond,
                endTime,
            },
        );

        expect(settingResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: stakingContract.address,
            success: true,
        });

        const systemData = await stakingContract.getSystemData();
        expect(systemData.rewardPerSecond).toBe(rewardPerSecond);
        expect(systemData.endTime).toBe(endTime);
    });

    it('staker stake 5: ', async () => {
        const stakingBalanceBefore = await stakingContract.getBalance();
        console.log('stakingBalanceBefore: ', stakingBalanceBefore);

        const amount = toNano('5');
        const stakingResult = await stakingContract.send(
            staker.getSender(),
            {
                value: toNano('10'),
            },
            {
                $$type: 'Stake',
                amount,
            },
        );

        expect(stakingResult.transactions).toHaveTransaction({
            from: staker.address,
            to: stakingContract.address,
            success: true,
        });

        const stakingBalanceAfter = await stakingContract.getBalance();
        console.log('stakingBalanceAfter: ', stakingBalanceAfter);

        let stakerContractAddress = await stakingContract.getStakerAddress(staker.address);

        stakerContract = blockchain.openContract(Staker.fromAddress(stakerContractAddress));

        // const stakerBalance = await stakerContract.getBalance();
        // console.log('stakerBalance: ', stakerBalance);
        const stakerData = await stakerContract.getStakerData();
        expect(stakerData.staked).toBe(amount);
        // console.log('stakerData:  ', stakerData);
        const systemData = await stakingContract.getSystemData();
        // console.log('systemData:  ', systemData);
        expect(systemData.totalStaked).toBe(amount);
    });

    it('increase time check systemIndex: 10s', async () => {
        await sleep(9800); // 9.8s
        const systemData = await stakingContract.getSystemData();
        const systemIndex = systemData.systemIndex;

        const stakerReward = await stakerContract.getUserReward(systemIndex);
        console.log('stakerReward: ', stakerReward);
    }, 100000);

    it('staker unstake 1/2 = 2.5: ', async () => {
        const amount = toNano('2.5');
        const stakingResult = await stakingContract.send(
            staker.getSender(),
            {
                value: toNano('1'),
            },
            {
                $$type: 'Unstake',
                amount,
            },
        );

        expect(stakingResult.transactions).toHaveTransaction({
            from: staker.address,
            to: stakingContract.address,
            success: true,
        });

        // const stakerBalance = await stakerContract.getBalance();
        // console.log('stakerBalance: ', stakerBalance);
        const stakerData = await stakerContract.getStakerData();
        expect(stakerData.staked).toBe(amount);
        expect(stakerData.unclaimedReward).toBe(toNano('10')); // since 1 ton per second
        // console.log('stakerData:  ', stakerData);
        const systemData = await stakingContract.getSystemData();
        // console.log('systemData:  ', systemData);
        expect(systemData.totalStaked).toBe(amount);
    });

    it('staker claim reward: ', async () => {
        const stakingBalanceBefore = await stakingContract.getBalance();
        console.log('stakingBalanceBefore: ', stakingBalanceBefore);

        const amount = toNano('10');
        const stakingResult = await stakingContract.send(
            staker.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'ClaimReward',
                amount,
            },
        );

        expect(stakingResult.transactions).toHaveTransaction({
            from: staker.address,
            to: stakingContract.address,
            success: true,
        });

        const stakingBalanceAfter = await stakingContract.getBalance();
        console.log('stakingBalanceAfter: ', stakingBalanceAfter);

        const stakerBalance = await stakerContract.getBalance();
        console.log('stakerBalance: ', stakerBalance);

        const stakerData = await stakerContract.getStakerData();
        expect(stakerData.unclaimedReward).toBe(toNano('0')); // since claimed all 10 TON
        // console.log('stakerData:  ', stakerData);
        const systemData = await stakingContract.getSystemData();
        // console.log('systemData:  ', systemData);
    });

    it('Pause to test revert case: ', async () => {
        const txResult = await stakerContract.send(
            staker.getSender(),
            {
                value: toNano('0.2'),
            },
            {
                $$type: 'Pause',
            },
        );

        expect(txResult.transactions).toHaveTransaction({
            from: staker.address,
            to: stakingContract.address,
            success: true,
        });
    });
});
