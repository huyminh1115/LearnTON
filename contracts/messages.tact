struct SystemData{
    totalStaked: Int;
    totalClaimed: Int;
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

message Pause {
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

message BackToOwner {
}

message WithdrawLeftOver {
}

const minTonsForStorage: Int = ton("0.02");
const gasConsumption: Int = ton("0.2");
const PADDING: Int = ton("1");