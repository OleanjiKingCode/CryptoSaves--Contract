// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "lib/";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title LOCK YEAR CONTRACT
/// @author Oleanji
/// @notice A contracts that locks funds for a year

contract EtherLockup is Ownable(msg.sender) {
    using SafeMath for uint256;

    struct Lockup {
        uint256 amount;
        uint256 releaseTime;
        bool locked;
    }

    mapping(address => Lockup) public lockups;

    event EtherLocked(address indexed owner, uint256 amount, uint256 releaseTime);
    event EtherUnlocked(address indexed owner, uint256 amount);
    event LockupExtended(address indexed owner, uint256 releaseTime);

    modifier onlyOwnerOrUnlocked() {
        require(msg.sender == owner() || !lockups[msg.sender].locked, "Not the owner or Ether is locked");
        _;
    }

    modifier onlyUnlocked() {
        require(!lockups[msg.sender].locked, "Ether is locked");
        _;
    }

    function lockEther(uint256 _releaseTime) external payable onlyOwnerOrUnlocked {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_releaseTime > block.timestamp, "Release time must be in the future");

        lockups[msg.sender] = Lockup({
            amount: msg.value,
            releaseTime: _releaseTime,
            locked: true
        });

        emit EtherLocked(msg.sender, msg.value, _releaseTime);
    }

    function unlockEther() external onlyOwnerOrUnlocked {
        require(lockups[msg.sender].locked, "Ether is not locked");
        require(block.timestamp >= lockups[msg.sender].releaseTime, "Release time has not arrived");

        uint256 amountToTransfer = lockups[msg.sender].amount;
        lockups[msg.sender].amount = 0;
        lockups[msg.sender].locked = false;

        payable(msg.sender).transfer(amountToTransfer);

        emit EtherUnlocked(msg.sender, amountToTransfer);
    }

    function extendLockup(uint256 _additionalMonths) external onlyOwnerOrUnlocked {
        require(_additionalMonths > 0, "Additional months must be greater than 0");
        require(lockups[msg.sender].locked, "Ether is not locked");

        uint256 newReleaseTime = lockups[msg.sender].releaseTime.add(_additionalMonths.mul(30 days));
        lockups[msg.sender].releaseTime = newReleaseTime;

        emit LockupExtended(msg.sender, newReleaseTime);
    }

    function getLockupDetails(address _user) external view returns (uint256, uint256, bool) {
        return (lockups[_user].amount, lockups[_user].releaseTime, lockups[_user].locked);
    }

    receive() external payable {
        // Fallback function to accept Ether transactions
    }
}
