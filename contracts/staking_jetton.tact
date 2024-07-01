import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages_stake_jetton";
import "./messages_jetton";
import "./staker_jetton";

contract StakingJetton with Deployable, Ownable {
    totalStaked: Int as coins;
    totalClaimed: Int as coins;
    systemIndex: Int as uint64;
    lastUpdateTimeStamp: Int as uint64;
    rewardPerSecond: Int as uint64;
    endTime: Int as uint64;
    owner: Address;
    jettonWallet: Address;

    init(_jettonWalletddress: Address) {
        self.owner = sender();
        self.totalStaked = 0;
        self.systemIndex = 0;
        self.lastUpdateTimeStamp = 0;
        self.rewardPerSecond = 0;
        self.endTime = 0;
        self.totalClaimed = 0;
        self.jettonWallet = _jettonWalletddress;
    }

    receive(msg: Setting) {
        self.requireOwner();
        self.rewardPerSecond = msg.rewardPerSecond;
        self.endTime = msg.endTime;
    }

    receive(stakeMsg: TokenNotification) {
        self.updateSystemIndex();

        let ctx: Context = context(); // get sender Info
        let msgValue: Int = ctx.value;

        require(msgValue >= gasConsumption, "Not enough gas");

        // Check sender is our jetton
        require(ctx.sender == self.jettonWallet, "Not correct jetton wallet");
        
        // Stake amount
        let stakeAmount: Int = stakeMsg.amount;

        // Update total staked
        self.totalStaked = self.totalStaked + stakeAmount;

        // Create message
        let init: StateInit = initOf StakerJetton(myAddress(), sender());

        let stakerAddress: Address = contractAddress(init);

        send(SendParameters{
            to: stakerAddress,
            value: 0, 
            bounce: true,
            mode: SendRemainingValue,
            body: UpdateStakeInternal{ 
                stakeAmount: stakeAmount,
                systemIndex: self.systemIndex,
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    bounced(src: UpdateStakeInternal){
        // Update total staked
        self.totalStaked = self.totalStaked - src.stakeAmount;

        let ctx: Context = context(); // get sender Info
        let stakerContract: Address = ctx.sender; // staker contract address

        // refund stake TON
        send(SendParameters{
            to: stakerContract,
            value: 0,
            bounce: false,
            body: BackToOwner{}.toCell(),
            mode: SendRemainingValue | SendIgnoreErrors,
        });
    }

    receive(msg: Unstake) {
        self.updateSystemIndex();

        let ctx: Context = context(); // get sender Info
        
        // Update total staked
        require(self.totalStaked > msg.amount, "Invalid unstake amount");
        self.totalStaked = self.totalStaked - msg.amount;

        // Create message
        let init: StateInit = initOf StakerJetton(myAddress(), sender());

        let stakerAddress: Address = contractAddress(init);

        send(SendParameters{
            to: stakerAddress, 
            value: 0, 
            bounce: true,
            mode: SendRemainingValue,
            body: UpdateUnstakeInternal{ 
                unstakeAmount: msg.amount,
                systemIndex: self.systemIndex,
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    bounced(src: UpdateUnstakeInternal){
        // Update total staked
        self.totalStaked = self.totalStaked + src.unstakeAmount;
    }

    receive(msg: ClaimReward) {
        self.updateSystemIndex();

        let ctx: Context = context(); // get sender Info
        
        require(myBalance() > msg.amount + minTonsForStorage, "Not enough money");
        
        // Create message
        let init: StateInit = initOf StakerJetton(myAddress(), sender());
        let stakerAddress: Address = contractAddress(init);

        // Update total claimed
        self.totalClaimed = self.totalClaimed + msg.amount;

        send(SendParameters{
            to: stakerAddress, 
            value: msg.amount, 
            bounce: true,
            mode: SendRemainingValue,
            body: UpdateClaimInternal{ 
                claimAmount: msg.amount,
                systemIndex: self.systemIndex,
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    bounced(src: UpdateClaimInternal){
        // Update total staked
        self.totalClaimed = self.totalClaimed - src.claimAmount;
    }


    fun updateSystemIndex() {
        if(self.rewardPerSecond > 0 && self.totalStaked > 0){
            self.systemIndex = self.getSystemIndex();
        }
        self.lastUpdateTimeStamp = now();
    }

    fun getSystemIndex(): Int {
        let newSystemIndex: Int = self.systemIndex;
        if(self.rewardPerSecond > 0 && self.totalStaked > 0){
            newSystemIndex = newSystemIndex + self.rewardPerSecond * PADDING * (now() - self.lastUpdateTimeStamp) / self.totalStaked;
        }
        return newSystemIndex;
    }

    get fun systemData(): SystemData{
        let newSystemIndex: Int = self.getSystemIndex();
        return SystemData{
            totalStaked: self.totalStaked,
            totalClaimed: self.totalClaimed,
            systemIndex: newSystemIndex,
            lastUpdateTimeStamp: self.lastUpdateTimeStamp,
            rewardPerSecond: self.rewardPerSecond,
            endTime: self.endTime,
        };
    }

    get fun balance(): String {
        return myBalance().toCoinsString();
    }

    get fun stakerAddress(staker: Address): Address {
        let init: StateInit = initOf StakerJetton(myAddress(), staker);
        return contractAddress(init);
    }


    // accept incoming TON transfers
    receive() {
    }
}
