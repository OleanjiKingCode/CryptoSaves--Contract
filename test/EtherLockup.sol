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
        assertEq(etherLockup.getLockupDetails(1).amount, 5e18);

        // second lockup
        etherLockup.lockEther{value: 50 ether}(6);
        assertEq(etherLockup.getLockupDetails(2).amount, 50e18);

        vm.stopPrank();
    }

    function testunlockEther() public {
        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 5 ether}(3);
        assertEq(etherLockup.getLockupDetails(1).amount, 5e18);

        // Locking up 50 ether for 6*30 days
        etherLockup.lockEther{value: 50 ether}(6);
        assertEq(etherLockup.getLockupDetails(2).amount, 50e18);

        // skips forward into the future to  3*30 days from now to be able to unlock
        skip(7776001);

        // unlocks
        etherLockup.unlockEther(1);
        assertEq(etherLockup.getLockupDetails(1).locked, false);
        assertEq(address(alice).balance, 10e18);

        // skips more forward into the future to  3*30 days
        // so a total of 6*30 days from now to be able to unlock
        skip(7776001);

        //second unlock
        etherLockup.unlockEther(2);
        assertEq(etherLockup.getLockupDetails(2).locked, false);
        assertEq(address(alice).balance, 60e18);

        vm.stopPrank();
    }

    function testextendLockup() public {
        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 5 ether}(3);
        assertEq(etherLockup.getLockupDetails(1).amount, 5e18);

        etherLockup.extendLockup(3, 1);
        assertGt(etherLockup.getLockupDetails(1).releaseTime, 7776001);
    }

    function testgetAllLockUps() public {
        vm.startPrank(alice);
        vm.deal(alice, 60 ether);

        // third lockup
        etherLockup.lockEther{value: 5 ether}(3);
        // second lockup
        etherLockup.lockEther{value: 7 ether}(6);
        //third lockup
        etherLockup.lockEther{value: 21 ether}(6);
        //fourth lockup
        etherLockup.lockEther{value: 11 ether}(6);

        // now check for all lockupdetails

        //first lockup
        assertEq(etherLockup.getAllLockUps()[1].amount, 5e18);
        assertEq(etherLockup.getAllLockUps()[1].locked, true);

        //second lockup
        assertEq(etherLockup.getAllLockUps()[2].amount, 7e18);
        assertEq(etherLockup.getAllLockUps()[2].locked, true);
        //third lockup
        assertEq(etherLockup.getAllLockUps()[4].amount, 11e18);
        assertEq(etherLockup.getAllLockUps()[4].locked, true);

        vm.stopPrank();
    }

    function testgetLockupDetails() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 10 ether}(3);
        assertEq(etherLockup.getLockupDetails(1).amount, 10e18);
        assertEq(etherLockup.getLockupDetails(1).locked, true);
        assertEq(etherLockup.getLockupDetails(1).lockId, 1);

        assertGt(
            etherLockup.getLockupDetails(1).releaseTime,
            3 * 30 * 24 * 60 * 60
        );
        // the months * days*hrs*min*sec
    }

    function testwithdraw() public {
        vm.deal(address(etherLockup), 4 ether);

        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        etherLockup.lockEther{value: 5 ether}(3);
        assertEq(etherLockup.getLockupDetails(1).locked, true);

        skip(7776001);

        //withdraws all the money in the contract
        etherLockup.withdraw();
        assertEq(address(alice).balance, 64e18);

        vm.stopPrank();
    }

    function testemergencyWithdraw() public {
        vm.deal(address(etherLockup), 48 ether);
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        etherLockup.lockEther{value: 6 ether}(3);
        assertEq(etherLockup.getLockupDetails(1).amount, 6e18);
        assertEq(
            etherLockup.getLockupDetails(1).amount + address(alice).balance,
            10e18
        );
        // the emergency withdraw time is after 8*30 daysso to to skip intime after then

        skip(8 * 30 * 24 * 60 * 60 + 1);

        //withdraws all the money in the contract for emergencies
        etherLockup.emergencyWithdraw();

        assertEq(address(alice).balance, 58e18);

        vm.stopPrank();
    }

    // function testlockEther() public {
    //     vm.startPrank(alice);
    //     /// crediting aka dealing 200 ethers to alice account
    //     vm.deal(alice, 200 ether);
    //     // first lockup
    //     etherLockup.lockEther{value: 5 ether}(3);

    //     console.log("\nThis are the details of the first lock Up");
    //     console.log("Lockup Id:", etherLockup.getLockupDetails(1).lockId);
    //     console.log("Lockup Amount:", etherLockup.getLockupDetails(1).amount);
    //     console.log(
    //         "Release Time:",
    //         etherLockup.getLockupDetails(1).releaseTime
    //     );
    //     assertEq(etherLockup.getLockupDetails(1).amount, 5e18);

    //     // second lockup
    //     etherLockup.lockEther{value: 50 ether}(6);
    //     assertEq(etherLockup.getLockupDetails(2).amount, 50e18);

    //     console.log("\nThis are the details of the second lock Up");
    //     console.log("Lockup Id:", etherLockup.getLockupDetails(2).lockId);
    //     console.log("Lockup Amount:", etherLockup.getLockupDetails(2).amount);
    //     console.log(
    //         "Release Time:",
    //         etherLockup.getLockupDetails(2).releaseTime
    //     );
    //     vm.stopPrank();
    // }

    // function testunlockEther() public {
    //     vm.startPrank(alice);
    //     vm.deal(alice, 60 ether);

    //     // Locking up 5 ether for 3*30 days
    //     etherLockup.lockEther{value: 5 ether}(3);

    //     console.log("\nThis are the details");
    //     console.log("Lockup Id:", etherLockup.getLockupDetails(1).lockId);
    //     console.log("Lockup Amount:", etherLockup.getLockupDetails(1).amount);
    //     console.log(
    //         "Release Time:",
    //         etherLockup.getLockupDetails(1).releaseTime
    //     );
    //     console.log("Is Locked:", etherLockup.getLockupDetails(1).locked);
    //     console.log(" Balnce After First LockUp:", address(alice).balance);

    //     // Locking up 50 ether for 6*30 days
    //     etherLockup.lockEther{value: 50 ether}(6);
    //     console.log("\nThis are the details");
    //     console.log("Lockup Id:", etherLockup.getLockupDetails(2).lockId);
    //     console.log("Lockup Amount:", etherLockup.getLockupDetails(2).amount);
    //     console.log(
    //         "Release Time:",
    //         etherLockup.getLockupDetails(2).releaseTime
    //     );
    //     console.log("Is Locked:", etherLockup.getLockupDetails(2).locked);
    //     console.log(" Balnce After Second LockUp:", address(alice).balance);

    //     // skips forward into the future to  3*30 days from now to be able to unlock
    //     skip(7776001);
    //     etherLockup.unlockEther(1);

    //     console.log("\nThis are the details");
    //     console.log("Lockup Id:", etherLockup.getLockupDetails(1).lockId);
    //     console.log("Lockup Amount:", etherLockup.getLockupDetails(1).amount);
    //     console.log(
    //         "Release Time:",
    //         etherLockup.getLockupDetails(1).releaseTime
    //     );
    //     console.log("Is Locked:", etherLockup.getLockupDetails(1).locked);
    //     console.log(" Balnce After First Unlock:", address(alice).balance);

    //     // skips more forward into the future to  3*30 days so a total of 6*30 days from now to be able to unlock
    //     skip(7776001);
    //     etherLockup.unlockEther(2);

    //     console.log("\nThis are the details");
    //     console.log("Lockup Id:", etherLockup.getLockupDetails(2).lockId);
    //     console.log("Lockup Amount:", etherLockup.getLockupDetails(2).amount);
    //     console.log(
    //         "Release Time:",
    //         etherLockup.getLockupDetails(2).releaseTime
    //     );
    //     console.log("Is Locked:", etherLockup.getLockupDetails(2).locked);
    //     console.log(" Balnce After Second Unlock:", address(alice).balance);
    // }

    //  function testwithdraw() public {
    //     vm.deal(address(etherLockup), 4 ether);

    //     vm.startPrank(alice);

    //     vm.deal(alice, 60 ether);

    //     etherLockup.lockEther{value: 5 ether}(3);
    //     assertEq(etherLockup.getLockupDetails(1).locked, true);

    //     skip(7776001);

    //     etherLockup.withdraw();

    //     console.log(
    //         address(etherLockup).balance,
    //         address(alice).balance,
    //         etherLockup.getLockupDetails(1).releaseTime
    //     );
    // }
}
