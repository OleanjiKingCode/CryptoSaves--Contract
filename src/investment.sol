// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Counters} from "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";

/// @title LOCK YEAR CONTRACT
/// @author Oleanji
/// @notice A contracts that locks funds for a year

contract EtherLockup is Ownable(msg.sender) {
    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------
    struct Lockup {
        uint256 lockId;
        uint256 amount;
        uint256 releaseTime;
        bool locked;
    }

    /// -----------------------------------------------------------------------
    ///  Inheritances
    /// -----------------------------------------------------------------------
    using Counters for Counters.Counter;

    /// -----------------------------------------------------------------------
    /// Mappings
    /// -----------------------------------------------------------------------
    mapping(uint256 => Lockup) public lockups;

    /// -----------------------------------------------------------------------
    /// Variables
    /// -----------------------------------------------------------------------
    uint256 emergencyTime;
    Counters.Counter private lockIdTracker;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------
    constructor() {
        lockIdTracker.increment();
        emergencyTime = block.timestamp + (8 * 30 days);
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @notice locks your ether for a specific amount of month
    /// @param _months the number of months to lock the ether for
    function lockEther(uint256 _months) external payable onlyOwner {
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 releaseTime = block.timestamp + (_months * 30 days);
        uint256 lockId = lockIdTracker.current();
        lockups[lockId] = Lockup(lockId, msg.value, releaseTime, true);
        lockIdTracker.increment();
        emit EtherLocked(lockId, msg.sender, msg.value, releaseTime);
    }

    /// @notice unlocks ether when the unlock date has reached
    /// @param _lockId the Id of the lockUp you want to unlock
    function unlockEther(uint256 _lockId) external onlyOwner {
        require(lockups[_lockId].locked, "Ether is not locked");
        require(
            block.timestamp >= lockups[_lockId].releaseTime,
            "Release time has not arrived"
        );

        uint256 amountToTransfer = lockups[_lockId].amount;
        lockups[_lockId].amount = 0;
        lockups[_lockId].locked = false;
        payable(msg.sender).transfer(amountToTransfer);
        emit EtherUnlocked(_lockId, msg.sender, amountToTransfer);
    }

    /// @notice extends lock time ether when the unlock date has reached
    /// @param _lockId the Id of the lockUp you want to edit its date
    /// @param _additionalMonths the number of months to increase the lock up for
    function extendLockup(
        uint256 _additionalMonths,
        uint256 _lockId
    ) external onlyOwner {
        require(
            _additionalMonths > 0,
            "Additional months must be greater than 0"
        );
        require(lockups[_lockId].locked, "Ether is not locked");

        uint256 newReleaseTime = lockups[_lockId].releaseTime +
            (_additionalMonths * 30 days);
        lockups[_lockId].releaseTime = newReleaseTime;

        emit LockupExtended(_lockId, msg.sender, newReleaseTime);
    }

    /// @notice Gets all the Lockups created
    function getAllLockUps() external view returns (Lockup[] memory) {
        uint256 total = lockIdTracker.current();
        Lockup[] memory lockup = new Lockup[](total);
        for (uint256 i = 1; i < total; i++) {
            lockup[i] = lockup[i];
        }
        return lockup;
    }

    /// @notice Gets specific lock up details
    /// @param _lockId the Id of the lockUp you want details for
    function getLockupDetails(
        uint256 _lockId
    ) external view returns (Lockup memory) {
        Lockup memory lockDetails = lockups[_lockId];
        return (lockDetails);
    }

    /// @notice Withdraws all amount in the contract as long as you have locked once
    function withdraw() external onlyOwner {
        uint256 currentId = lockIdTracker.current();
        require(
            lockups[currentId].releaseTime <= block.timestamp,
            "Time for withdrawal hasnt reached"
        );
        uint256 amountToTransfer = address(this).balance;
        payable(msg.sender).transfer(amountToTransfer);
    }

    /// @notice Withdraws all amount in the contract as long as 240 days have passed
    function emergencyWithdraw() external onlyOwner {
        uint256 currentId = lockIdTracker.current();
        require(
            currentId > 0 || address(this).balance > 0,
            "No locking has been done"
        );
        require(
            lockups[currentId].releaseTime >= emergencyTime ||
                block.timestamp >= emergencyTime,
            "Time for emergency hasnt reached. keep fighting!!!"
        );
        uint256 amountToTransfer = address(this).balance;
        payable(msg.sender).transfer(amountToTransfer);
    }

    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event EtherLocked(
        uint256 indexed id,
        address owner,
        uint256 amount,
        uint256 releaseTime
    );
    event EtherUnlocked(uint256 indexed id, address owner, uint256 amount);
    event LockupExtended(
        uint256 indexed id,
        address owner,
        uint256 releaseTime
    );
}
