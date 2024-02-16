// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EtherLockup.sol";
import "forge-std/console.sol";

contract EtherLockupCheatsTest is Test {
    EtherLockup public etherLockup;
    address alice = vm.addr(0x2);

    function setUp() public {
        vm.startPrank(alice);
        etherLockup = new EtherLockup();
        vm.stopPrank();
    }

    function testlockEther() public {
        vm.startPrank(alice);
        /// crediting aka dealing 200 ethers to alice account
        vm.deal(alice, 200 ether);
        // first lockup
        etherLockup.lockEther{value: 5 ether}(3);

        console.log("\nThis are the details of the first lock Up");
        console.log("Lockup Id:", etherLockup.getLockupDetails(1).lockId);
        console.log("Lockup Amount:", etherLockup.getLockupDetails(1).amount);
        console.log(
            "Release Time:",
            etherLockup.getLockupDetails(1).releaseTime
        );
        assertEq(etherLockup.getLockupDetails(1).amount, 5e18);

        // second lockup
        etherLockup.lockEther{value: 50 ether}(6);
        assertEq(etherLockup.getLockupDetails(2).amount, 50e18);

        console.log("\nThis are the details of the second lock Up");
        console.log("Lockup Id:", etherLockup.getLockupDetails(2).lockId);
        console.log("Lockup Amount:", etherLockup.getLockupDetails(2).amount);
        console.log(
            "Release Time:",
            etherLockup.getLockupDetails(2).releaseTime
        );
        vm.stopPrank();
    }

    function testunlockEther() public {
        vm.startPrank(alice);
        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 5 ether}(3);

        console.log("\nThis are the details");
        console.log("Lockup Id:", etherLockup.getLockupDetails(1).lockId);
        console.log("Lockup Amount:", etherLockup.getLockupDetails(1).amount);
        console.log(
            "Release Time:",
            etherLockup.getLockupDetails(1).releaseTime
        );
        console.log("Is Locked:", etherLockup.getLockupDetails(1).locked);
        console.log(" Balnce After First LockUp:", address(alice).balance);

        // Locking up 50 ether for 6*30 days
        etherLockup.lockEther{value: 50 ether}(6);
        console.log("\nThis are the details");
        console.log("Lockup Id:", etherLockup.getLockupDetails(2).lockId);
        console.log("Lockup Amount:", etherLockup.getLockupDetails(2).amount);
        console.log(
            "Release Time:",
            etherLockup.getLockupDetails(2).releaseTime
        );
        console.log("Is Locked:", etherLockup.getLockupDetails(2).locked);
        console.log(" Balnce After Second LockUp:", address(alice).balance);

        // skips forward into the future to  3*30 days from now to be able to unlock
        skip(7776001);
        etherLockup.unlockEther(1);

        console.log("\nThis are the details");
        console.log("Lockup Id:", etherLockup.getLockupDetails(1).lockId);
        console.log("Lockup Amount:", etherLockup.getLockupDetails(1).amount);
        console.log(
            "Release Time:",
            etherLockup.getLockupDetails(1).releaseTime
        );
        console.log("Is Locked:", etherLockup.getLockupDetails(1).locked);
        console.log(" Balnce After First Unlock:", address(alice).balance);

        // skips more forward into the future to  3*30 days so a total of 6*30 days from now to be able to unlock
        skip(7776001);
        etherLockup.unlockEther(2);

        console.log("\nThis are the details");
        console.log("Lockup Id:", etherLockup.getLockupDetails(2).lockId);
        console.log("Lockup Amount:", etherLockup.getLockupDetails(2).amount);
        console.log(
            "Release Time:",
            etherLockup.getLockupDetails(2).releaseTime
        );
        console.log("Is Locked:", etherLockup.getLockupDetails(2).locked);
        console.log(" Balnce After Second Unlock:", address(alice).balance);
    }

    function testwithdraw() public {
        vm.deal(address(etherLockup), 4 ether);
        vm.startPrank(alice);
        vm.deal(alice, 60 ether);
        etherLockup.lockEther{value: 5 ether}(3);
        skip(7776001);
        etherLockup.withdraw();
        console.log(
            address(etherLockup).balance,
            address(alice).balance,
            etherLockup.getLockupDetails(1).releaseTime
        );
    }
}
