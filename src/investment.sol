// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Counters} from "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";

/// @title LOCK YEAR CONTRACT
/// @author Oleanji
/// @notice A contracts that locks funds for a year

contract EtherLockup is Ownable(msg.sender) {
    using Counters for Counters.Counter;

    Counters.Counter private lockIdTracker;
    struct Lockup {
        uint256 lockId;
        uint256 amount;
        uint256 releaseTime;
        bool locked;
    }

    mapping(uint256 => Lockup) public lockups;

    constructor() {
        lockIdTracker.increment();
    }

    event EtherLocked(
        uint256 indexed id,
        address owner,
        uint256 amount,
        uint256 releaseTime
    );
    event EtherUnlocked(uint256 indexed id,address owner, uint256 amount);
    event LockupExtended(uint256 indexed id,address owner, uint256 releaseTime);

    modifier onlyOwnerOrUnlocked() {
        require(
            msg.sender == owner(),
            "Not the owner "
        );
        _;
    }

    // modifier onlyUnlocked() {
    //     require(!lockups[msg.sender].locked, "Ether is locked");
    //     _;
    // }

    function lockEther(uint256 _months) external payable onlyOwnerOrUnlocked {
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 releaseTime = block.timestamp + (_months * 30 days);
        uint256 lockId = lockIdTracker.current();

        lockups[lockId] = Lockup(
            lockId,
            msg.value,
            releaseTime,
            true
        );
 lockIdTracker.increment();
        emit EtherLocked(lockId,msg.sender, msg.value, releaseTime);
    }

    function unlockEther(uint256 _lockId) external onlyOwnerOrUnlocked {
        require(lockups[_lockId].locked, "Ether is not locked");
        require(
            block.timestamp >= lockups[_lockId].releaseTime,
            "Release time has not arrived"
        );

        uint256 amountToTransfer = lockups[_lockId].amount;
        lockups[_lockId].amount = 0;
        lockups[_lockId].locked = false;

        payable(msg.sender).transfer(amountToTransfer);

        emit EtherUnlocked(_lockId,msg.sender, amountToTransfer);
    }

    function extendLockup(
        uint256 _additionalMonths,
        uint256 _lockId
    ) external onlyOwnerOrUnlocked {
        require(
            _additionalMonths > 0,
            "Additional months must be greater than 0"
        );
        require(lockups[_lockId].locked, "Ether is not locked");

        uint256 newReleaseTime = lockups[_lockId].releaseTime +
            (_additionalMonths * 30 days);
        lockups[_lockId].releaseTime = newReleaseTime;

        emit LockupExtended(_lockId,msg.sender, newReleaseTime);
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

    function getLockupDetails(
        uint256 _lockId
    ) external view returns (Lockup memory) {
        Lockup memory lockDetails = lockups[_lockId];
        return (lockDetails);
    }

    receive() external payable {
        // Fallback function to accept Ether transactions
    }
}
