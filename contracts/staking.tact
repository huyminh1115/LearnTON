import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages";
import "./staker";

contract Staking with Deployable, Ownable {
    totalStaked: Int as coins;
    systemIndex: Int as uint64;
    lastUpdateTimeStamp: Int as uint64;
    rewardPerSecond: Int as uint64;
    endTime: Int as uint64;
    owner: Address;

    init(rewardPerSecond: Int) {
        self.owner = sender();
        self.totalStaked = 0;
        self.systemIndex = 0;
        self.lastUpdateTimeStamp = 0;
        self.rewardPerSecond = rewardPerSecond;
        self.endTime = 0;
    }

    receive(msg: Setting) {
        self.requireOwner();
        self.rewardPerSecond = msg.rewardPerSecond;
        self.endTime = msg.endTime;
    }

    receive(msg: Stake) {
        self.updateSystemIndex();

        let ctx: Context = context(); // get sender Info
        let msgValue: Int = ctx.value;

        require(msgValue >= msg.amount, "Not enough TON");
        
        // Update total staked
        self.totalStaked = self.totalStaked + msg.amount;

        // Create message
        let init: StateInit = initOf Staker(myAddress(), sender());

        let stakerAddress: Address = contractAddress(init);

        send(SendParameters{
            to: stakerAddress, 
            value: 0, 
            bounce: true,
            mode: SendRemainingValue, // staker contract will hold staking amount
            body: UpdateStakeInternal{ 
                stakeAmount: msg.amount,
                systemIndex: self.systemIndex,
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive(msg: Unstake) {
        self.updateSystemIndex();

        let ctx: Context = context(); // get sender Info
        
        // Update total staked
        require(self.totalStaked > msg.amount, "Invalid unstake amount");
        self.totalStaked = self.totalStaked - msg.amount;

        // Create message
        let init: StateInit = initOf Staker(myAddress(), sender());

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

    receive(msg: ClaimReward) {
        self.updateSystemIndex();

        let ctx: Context = context(); // get sender Info
        
        // Create message
        let init: StateInit = initOf Staker(myAddress(), sender());

        require(myBalance() > msg.amount + minTonsForStorage, "Not enough money");
        
        let stakerAddress: Address = contractAddress(init);

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

    fun updateSystemIndex() {
        if(self.rewardPerSecond > 0 && self.totalStaked > 0){
            let oldSystemIndex: Int = self.systemIndex;
            self.systemIndex = oldSystemIndex + self.rewardPerSecond * PADDING * (now() - self.lastUpdateTimeStamp)/ self.totalStaked;
            self.lastUpdateTimeStamp = now();
        }
    }

    get fun systemData(): SystemData{
        return SystemData{
            totalStaked: self.totalStaked,
            systemIndex: self.systemIndex,
            lastUpdateTimeStamp: self.lastUpdateTimeStamp,
            rewardPerSecond: self.rewardPerSecond,
            endTime: self.endTime,
            };
    }

    get fun balance(): String {
        return myBalance().toCoinsString();
    }

    // accept incoming TON transfers
    receive() {
    }
}
