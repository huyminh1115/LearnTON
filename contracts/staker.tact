import "@stdlib/deploy";
import "./messages";

contract Staker with Deployable {
    stakingContract: Address;
    owner: Address;
    userIndex: Int as uint64;
    unclaimedReward: Int as coins;
    staked: Int as coins;
    paused: Bool;

    init(stakingContract: Address, owner: Address) {
        self.stakingContract = stakingContract;
        self.owner = owner;
        self.staked = 0;
        self.unclaimedReward = 0;
        self.userIndex = 0;
        self.paused = false;
    }

    receive(msg: Pause) {
        self.paused = !self.paused;
    }

    receive(msg: BackToOwner) {
        send(SendParameters{
                to: self.owner,
                bounce: false,
                value: 0,
                mode: SendRemainingValue | SendIgnoreErrors
        });
    }

    receive(msg: WithdrawLeftOver) {
        let balance: Int = myBalance();
        let stakedAmount: Int = self.staked;
        let returnAmount: Int = 0;

        if(balance > stakedAmount){
            returnAmount = balance - stakedAmount;
        }

        send(SendParameters{
                to: self.owner,
                bounce: false,
                value: returnAmount,
                mode: SendRemainingValue | SendIgnoreErrors
        });
    }

    receive(msg: UpdateStakeInternal) {
        require(!self.paused, "Paused!");
        require(sender() == self.stakingContract, "Admin contract only");
        self.updateStaker(msg.systemIndex);
        self.staked = self.staked + msg.stakeAmount;
    }

    receive(msg: UpdateUnstakeInternal) {
        require(!self.paused, "Paused!");
        require(sender() == self.stakingContract, "Admin contract only");
    
        self.updateStaker(msg.systemIndex);

        if(msg.unstakeAmount > 0){
            require(msg.unstakeAmount <= self.staked, "Invalid unstake amount");
            self.staked = self.staked - msg.unstakeAmount;
            let withdrawAmount: Int = min(msg.unstakeAmount, myBalance() - minTonsForStorage);
            send(SendParameters{
                to: self.owner,
                bounce: false,
                value: withdrawAmount,
                mode: SendRemainingValue + SendIgnoreErrors
            });
        }
    }

    receive(msg: UpdateClaimInternal) {
        require(sender() == self.stakingContract, "Admin contract only");
    
        self.updateStaker(msg.systemIndex);

        require(self.unclaimedReward >= msg.claimAmount, "Invalid reward");

        self.unclaimedReward = self.unclaimedReward - msg.claimAmount;
        
        send(SendParameters{
            to: self.owner,
            bounce: false,
            value: 0,
            mode: SendRemainingValue + SendIgnoreErrors // all value form message from staking contract
        });
    }


    fun updateStaker(systemIndex: Int) {
        if(systemIndex > self.userIndex){
            if(self.staked != 0){
                let unclaimedReward: Int = self.unclaimedReward;
                self.unclaimedReward = unclaimedReward + (systemIndex - self.userIndex) * self.staked / PADDING;
            }
        }
        self.userIndex = systemIndex;
    }

    get fun balance(): String {
        return myBalance().toCoinsString();
    }

    get fun stakerData(): StakerData{
        return StakerData{
            staked: self.staked,
            userIndex: self.userIndex,
            unclaimedReward: self.unclaimedReward,
        };
    }

    get fun userReward(systemIndex: Int): String {
        let unclaimedReward: Int = self.unclaimedReward;
        return (unclaimedReward + (systemIndex - self.userIndex) * self.staked / PADDING).toCoinsString();
    }

    // accept incoming TON transfers
    receive() {
    }

}
