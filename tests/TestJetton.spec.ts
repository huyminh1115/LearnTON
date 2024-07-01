import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { Cell, toNano } from '@ton/core';
import { Jetton } from '../wrappers/Jetton';
import { SampleJetton } from '../wrappers/SampleJetton';
import { JettonDefaultWallet } from '../wrappers/JettonDefaultWallet';
import '@ton/test-utils';

describe('Jetton', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let user: SandboxContract<TreasuryContract>;
    let user2: SandboxContract<TreasuryContract>;
    let jetton: SandboxContract<SampleJetton>;
    let systemDefaultWallet: SandboxContract<JettonDefaultWallet>;

    beforeAll(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');
        user = await blockchain.treasury('user');
        user2 = await blockchain.treasury('user2');

        jetton = blockchain.openContract(
            await SampleJetton.fromInit(deployer.address, new Cell(), BigInt('10000000000000000000')),
        );

        const deployResult = await jetton.send(
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
            to: jetton.address,
            deploy: true,
            success: true,
        });
    });

    it('Mint user token', async () => {
        const mintResult = await jetton.send(
            deployer.getSender(),
            {
                value: toNano('1'),
            },
            'Mint: 1000000000000000000',
        );

        expect(mintResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: jetton.address,
            success: true,
        });

        const systemAddress = await jetton.getGetWalletAddress(deployer.address);
        console.log('systemAddress: ', systemAddress);
        systemDefaultWallet = blockchain.openContract(JettonDefaultWallet.fromAddress(systemAddress));
        let walletData = await systemDefaultWallet.getGetWalletData();
        console.log('token balance: ', walletData.balance);
        console.log('token owner: ', walletData.owner);
        console.log('token master: ', walletData.master);
    });
});
