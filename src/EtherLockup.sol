// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/// @title LOCK YEAR CONTRACT
/// @author Oleanji
/// @notice A contracts that locks funds for a year

contract EtherLockup is Ownable(msg.sender) {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------
    error CannotLockZeroEther();
    error LockupIsntLocked();
    error UnlockTimeHasNotReached();
    error AdditionalMonthsShouldBeMoreThanZero();
    error NoLockupHasBeenDone();

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------
    struct Lockup {
        uint256 lockId;
        string name;
        string lockType;
        uint256 amount;
        uint256 releaseTime;
        bool locked;
    }

    /// -----------------------------------------------------------------------
    /// Mappings
    /// -----------------------------------------------------------------------
    mapping(uint256 => Lockup) public lockups;

    /// -----------------------------------------------------------------------
    /// Variables
    /// -----------------------------------------------------------------------
    uint256 public emergencyUnlockTimestamp;
    uint private lockIdTracker;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------
    constructor() {
        lockIdTracker += 1;
        emergencyUnlockTimestamp = block.timestamp + (8 * 30 days);
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @notice locks your ether for a specific amount of month
    /// @param _months the number of months to lock the ether for
    function lockEther(
        uint256 _months,
        string memory _name,
        string memory _lockType
    ) external payable onlyOwner {
        if (msg.value <= 0) revert CannotLockZeroEther();
        uint256 releaseTime = block.timestamp + (_months * 30 days);
        uint256 lockId = lockIdTracker;
        lockups[lockId] = Lockup(
            lockId,
            _name,
            _lockType,
            msg.value,
            releaseTime,
            true
        );
        lockIdTracker += 1;
        emit EtherLocked(
            lockId,
            _name,
            msg.sender,
            msg.value,
            releaseTime,
            _lockType
        );
    }

    /// @notice unlocks ether when the unlock date has reached
    /// @param _lockId the Id of the lockUp you want to unlock
    function unlockEther(uint256 _lockId) external onlyOwner {
        if (!lockups[_lockId].locked) revert LockupIsntLocked();
        if (block.timestamp < lockups[_lockId].releaseTime)
            revert UnlockTimeHasNotReached();
        uint256 amountToTransfer = lockups[_lockId].amount;
        lockups[_lockId].amount = 0;
        lockups[_lockId].locked = false;
        payable(msg.sender).transfer(amountToTransfer);
        emit EtherUnlocked(
            _lockId,
            lockups[_lockId].name,
            msg.sender,
            amountToTransfer
        );
    }

    /// @notice extends lock time ether when the unlock date has reached
    /// @param _lockId the Id of the lockUp you want to edit its date
    /// @param _additionalMonths the number of months to increase the lock up for
    function extendLockup(
        uint256 _additionalMonths,
        uint256 _lockId
    ) external onlyOwner {
        if (_additionalMonths <= 0)
            revert AdditionalMonthsShouldBeMoreThanZero();
        if (!lockups[_lockId].locked) revert LockupIsntLocked();
        uint256 newReleaseTime = lockups[_lockId].releaseTime +
            (_additionalMonths * 30 days);
        lockups[_lockId].releaseTime = newReleaseTime;
        emit LockupExtended(
            _lockId,
            lockups[_lockId].name,
            msg.sender,
            newReleaseTime
        );
    }

    /// @notice Gets all the Lockups created
    function getAllLockUps() external view returns (Lockup[] memory) {
        uint256 total = lockIdTracker;
        Lockup[] memory lockup = new Lockup[](total);
        for (uint256 i = 1; i < total; i++) {
            lockup[i] = lockups[i];
        }
        return lockup;
    }

    /// @notice Gets specific lock up details
    /// @param _lockId the Id of the lockUp you want details for
    function getLockupDetailsById(
        uint256 _lockId
    ) external view returns (Lockup memory) {
        Lockup memory lockDetails = lockups[_lockId];
        return (lockDetails);
    }

    /// @notice Withdraws all amount in the contract as long as you have locked once
    function withdraw() external onlyOwner {
        uint256 currentId = lockIdTracker;
        if (block.timestamp < lockups[currentId - 1].releaseTime)
            revert UnlockTimeHasNotReached();
        uint256 amountToTransfer = address(this).balance;
        payable(msg.sender).transfer(amountToTransfer);
    }

    /// @notice Withdraws all amount in the contract as long as 240 days have passed
    function emergencyWithdraw() external onlyOwner {
        uint256 currentId = lockIdTracker;
        if (currentId <= 0 || address(this).balance <= 0)
            revert NoLockupHasBeenDone();
        if (
            emergencyUnlockTimestamp > lockups[currentId].releaseTime &&
            emergencyUnlockTimestamp > block.timestamp
        ) revert UnlockTimeHasNotReached();
        uint256 amountToTransfer = address(this).balance;
        payable(msg.sender).transfer(amountToTransfer);
    }

    /// @notice Used to receive ether
    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event EtherLocked(
        uint256 indexed id,
        string name,
        address owner,
        uint256 amount,
        uint256 releaseTime,
        string lockType
    );
    event EtherUnlocked(
        uint256 indexed id,
        string name,
        address owner,
        uint256 amount
    );
    event LockupExtended(
        uint256 indexed id,
        string name,
        address owner,
        uint256 releaseTime
    );
}
