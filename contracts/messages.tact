// message(0x178d4519) TokenTransferInternal {
//     queryId: Int as uint64;
//     amount: Int as coins;
//     from: Address;
//     responseAddress: Address?;
//     forwardTonAmount: Int as coins;
//     forwardPayload: Slice as remaining;
// }

// message(0x7362d09c) TokenNotification {
//     queryId: Int as uint64;
//     amount: Int as coins;
//     from: Address;
//     forwardPayload: Slice as remaining;
// }

// message(0x595f07bc) TokenBurn {
//     queryId: Int as uint64;
//     amount: Int as coins;
//     owner: Address;
//     responseAddress: Address?;
// }

// message(0x7bdd97de) TokenBurnNotification {
//     queryId: Int as uint64;
//     amount: Int as coins;
//     owner: Address;
//     responseAddress: Address?;
// }

// struct JettonWalletData {
//     balance: Int;
//     owner: Address;
//     master: Address;
//     walletCode: Cell;
// }

struct SystemData{
    totalStaked: Int;
    systemIndex: Int;
    lastUpdateTimeStamp: Int;
    rewardPerSecond: Int;
    endTime: Int;
}

struct StakerData{
    staked: Int;
    userIndex: Int;
    unclaimedReward: Int;
}

message Stake {
    amount: Int as coins;
}

message Unstake {
    amount: Int as coins;
}

message ClaimReward {
    amount: Int as coins;
}

message UpdateStakeInternal {
    stakeAmount: Int as coins;
    systemIndex: Int as uint64;
}

message UpdateUnstakeInternal {
    unstakeAmount: Int as coins;
    systemIndex: Int as uint64;
}

message UpdateClaimInternal {
    claimAmount: Int as coins;
    systemIndex: Int as uint64;
}

message Setting {
    rewardPerSecond: Int as uint64;
    endTime: Int as uint64;
}

const minTonsForStorage: Int = ton("0.02");
const gasConsumption: Int = ton("0.2");
const PADDING: Int = ton("1");