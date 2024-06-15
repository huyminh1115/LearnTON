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

    init() {
        self.owner = sender();
        self.totalStaked = 0;
        self.systemIndex = 0;
        self.lastUpdateTimeStamp = 0;
        self.rewardPerSecond = 0;
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
            bounce: false,
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
        
        require(myBalance() > msg.amount + minTonsForStorage, "Not enough money");
        
        // Create message
        let init: StateInit = initOf Staker(myAddress(), sender());
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
        let init: StateInit = initOf Staker(myAddress(), staker);
        return contractAddress(init);
    }


    // accept incoming TON transfers
    receive() {
    }
}
