# Ether Lockup Smart Contract

## Overview

This Solidity smart contract, named EtherLockup, allows users to lock their Ether for a specified period, and the locked funds can be unlocked or extended by the contract owner. It is designed to facilitate time-based locking of funds.

## Features

- **Lock Ether:** The contract owner can lock a specified amount of Ether for a defined number of months.
- **Unlock Ether:** The contract owner can unlock Ether once the specified release time is reached.
- **Extend Lockup:** The contract owner can extend the lockup period for a specific Ether lock.
- **Withdraw:** The contract owner can withdraw all the funds locked in the contract if the unlock time has been reached.
- **Emergency Withdraw:** The contract owner can perform an emergency withdrawal after a certain period.

## Getting Started

1. **Installation:**
   - Clone the repository.
   - Install necessary dependencies, including OpenZeppelin contracts.

2. **Deploying the Contract:**
   - Deploy the EtherLockup contract to a compatible Ethereum blockchain.

3. **Usage:**
   - Use the provided external functions to lock, unlock, extend, and manage Ether lockups.
   - Interact with the contract using a tool like Remix or deploy it programmatically.

## Contract Details

### Structs

- **Lockup:**
  - `lockId`: Identifier for each Ether lock.
  - `amount`: The amount of Ether locked.
  - `releaseTime`: The timestamp when the locked Ether can be unlocked.
  - `locked`: Boolean indicating whether the Ether is currently locked.

### External Functions

- `lockEther(uint256 _months):` Lock a specified amount of Ether for a given number of months.
  - **Parameters:**
    - `_months`: The number of months for which the Ether will be locked.
  - **Behavior:**
    - Checks if the provided amount of Ether is greater than zero.
    - Calculates the release time based on the current timestamp and the specified number of months.
    - Generates a unique lockId using the internal counter.
    - Creates a new lockup entry with the lockId, amount, releaseTime, and sets it as locked.
    - Emits an `EtherLocked` event.

- `unlockEther(uint256 _lockId):` Unlock Ether for a specific lockId if the release time has been reached.
  - **Parameters:**
    - `_lockId`: The identifier of the lockup to be unlocked.
  - **Behavior:**
    - Checks if the specified lockup is currently locked.
    - Checks if the current timestamp is greater than or equal to the release time.
    - Transfers the locked Ether amount to the contract owner.
    - Updates the lockup to set the amount to zero and mark it as unlocked.
    - Emits an `EtherUnlocked` event.

- `extendLockup(uint256 _additionalMonths, uint256 _lockId):` Extend the lockup period for a specific lockId.
  - **Parameters:**
    - `_additionalMonths`: The additional number of months to extend the lockup period.
    - `_lockId`: The identifier of the lockup to be extended.
  - **Behavior:**
    - Checks if the additional months to be added are greater than zero.
    - Checks if the specified lockup is currently locked.
    - Calculates the new release time based on the existing release time and additional months.
    - Updates the lockup's release time with the new calculated time.
    - Emits a `LockupExtended` event.

- `getAllLockUps():` Retrieve details of all lockups.
  - **Returns:**
    - An array of all lockup details (array of `Lockup` structs).

- `getLockupDetails(uint256 _lockId):` Retrieve details of a specific lockup.
  - **Parameters:**
    - `_lockId`: The identifier of the lockup to get details for.
  - **Returns:**
    - Details of the specified lockup (`Lockup` struct).

- `withdraw():` Withdraw all funds if the unlock time has been reached.
  - **Behavior:**
    - Checks if the unlock time of the latest lockup has been reached.
    - Transfers the entire balance of the contract to the contract owner.

- `emergencyWithdraw():` Perform an emergency withdrawal after a certain period.
  - **Behavior:**
    - Checks if there are any lockups recorded.
    - Checks if the unlock time of the latest lockup or the current timestamp is greater than the emergency time.
    - Transfers the entire balance of the contract to the contract owner.

## Events

- `EtherLocked(uint256 indexed id, address owner, uint256 amount, uint256 releaseTime):` Triggered when Ether is locked.
- `EtherUnlocked(uint256 indexed id, address owner, uint256 amount):` Triggered when Ether is unlocked.
- `LockupExtended(uint256 indexed id, address owner, uint256 releaseTime):` Triggered when the lockup period is extended.

## License

This smart contract is open-source and released under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

- **Oleanji**

