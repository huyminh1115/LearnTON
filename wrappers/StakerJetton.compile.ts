import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/staker_jetton.tact',
    options: {
        debug: true,
    },
};
