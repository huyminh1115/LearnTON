# Staking

## Project structure

-   `contracts` - source code of all the smart contracts of the project and their dependencies.
-   `wrappers` - wrapper classes (implementing `Contract` from ton-core) for the contracts, including any [de]serialization primitives and compilation functions.
-   `tests` - tests for the contracts.
-   `scripts` - scripts used by the project, mainly the deployment scripts.

## Contract

## Staking

This is the main contract, store all system data:

-   endTime: Distribute reward until this timestamp
-   systemIndex: System index
-   totalStaked: Total staked in the system
-   rewardPerSecond: Reward per second
-   lastUpdateTimeStamp: Last update timestamp

## Staker

Each staker will have this contract, store value of user staking data:

-   owner: staker address
-   staked: staked amount
-   userIndex: user index
-   unclaimedReward: unclaimed reward

## Flow

All flow start from Staking contract then update at Staker contract

User -> StakingContract -> StakerContract

## How to use

### Build

`npx blueprint build` or `yarn blueprint build`

### Test

`npx blueprint test` or `yarn blueprint test`

### Deploy or run another script

`npx blueprint run` or `yarn blueprint run`

### Add a new contract

`npx blueprint create ContractName` or `yarn blueprint create ContractName`

## Todo

Current work with happy case
Still haven't implement error case (having bounce function)
