// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EtherLockup.sol";
import "forge-std/console.sol";

contract EtherLockupCheatsTest is Test {
    EtherLockup public etherLockup;
    address alice = vm.addr(0x2);
    enum LockType {
        Family,
        Pets,
        Festivals,
        Fees,
        Reward,
        Travel,
        Others
    }

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
        etherLockup.lockEther{value: 5 ether}(
            3,
            "LockUpOne",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).amount, 5e18);

        // second lockup
        etherLockup.lockEther{value: 50 ether}(
            6,
            "LockUpTwo",
            EtherLockup.LockType.Family
        );
        assertEq(etherLockup.getLockupDetailsById(2).amount, 50e18);

        vm.stopPrank();
    }

    function testunlockEther() public {
        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 5 ether}(
            3,
            "My First LockUp",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).amount, 5e18);

        // Locking up 50 ether for 6*30 days
        etherLockup.lockEther{value: 50 ether}(
            6,
            "My Second LockUp",
            EtherLockup.LockType.Travel
        );
        assertEq(etherLockup.getLockupDetailsById(2).amount, 50e18);

        // skips forward into the future to  3*30 days from now to be able to unlock
        skip(7776001);

        // unlocks
        etherLockup.unlockEther(1);
        assertEq(etherLockup.getLockupDetailsById(1).locked, false);
        assertEq(address(alice).balance, 10e18);

        // skips more forward into the future to  3*30 days
        // so a total of 6*30 days from now to be able to unlock
        skip(7776001);

        //second unlock
        etherLockup.unlockEther(2);
        assertEq(etherLockup.getLockupDetailsById(2).locked, false);
        assertEq(address(alice).balance, 60e18);

        vm.stopPrank();
    }

    function testextendLockup() public {
        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 5 ether}(
            3,
            "LockUpOne",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).amount, 5e18);

        etherLockup.extendLockup(3, 1);
        assertGt(etherLockup.getLockupDetailsById(1).releaseTime, 7776001);
    }

    function testgetAllLockUps() public {
        vm.startPrank(alice);
        vm.deal(alice, 60 ether);

        // third lockup
        etherLockup.lockEther{value: 5 ether}(
            3,
            "LockUpOne",
            EtherLockup.LockType.Fees
        );
        // second lockup
        etherLockup.lockEther{value: 7 ether}(
            6,
            "LockUpTwo",
            EtherLockup.LockType.Fees
        );
        //third lockup
        etherLockup.lockEther{value: 21 ether}(
            6,
            "LockUpThree",
            EtherLockup.LockType.Pets
        );
        //fourth lockup
        etherLockup.lockEther{value: 11 ether}(
            6,
            "LockUpFour",
            EtherLockup.LockType.Festivals
        );

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

    function testgetLockupDetailsById() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        // Locking up 5 ether for 3*30 days
        etherLockup.lockEther{value: 10 ether}(
            3,
            "LockUpOne",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).amount, 10e18);
        assertEq(etherLockup.getLockupDetailsById(1).locked, true);
        assertEq(etherLockup.getLockupDetailsById(1).lockId, 1);

        assertGt(
            etherLockup.getLockupDetailsById(1).releaseTime,
            3 * 30 * 24 * 60 * 60
        );
        // the months * days*hrs*min*sec
    }

    function testwithdraw() public {
        vm.deal(address(etherLockup), 4 ether);

        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        etherLockup.lockEther{value: 5 ether}(
            3,
            "LockUpOne",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).locked, true);

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

        etherLockup.lockEther{value: 6 ether}(
            3,
            "My First LockUp",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).amount, 6e18);
        assertEq(
            etherLockup.getLockupDetailsById(1).amount + address(alice).balance,
            10e18
        );
        // the emergency withdraw time is after 8*30 daysso to to skip intime after then

        skip(8 * 30 * 24 * 60 * 60 + 1);

        //withdraws all the money in the contract for emergencies
        etherLockup.emergencyWithdraw();

        assertEq(address(alice).balance, 58e18);

        vm.stopPrank();
    }

    function testCannotLockZeroEther() public {
        vm.startPrank(alice);
        vm.expectRevert(EtherLockup.CannotLockZeroEther.selector);
        etherLockup.lockEther{value: 0 ether}(
            3,
            "First Locking",
            EtherLockup.LockType.Pets
        );
        vm.stopPrank();
    }

    function testLockupIsntLocked() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        etherLockup.lockEther{value: 6 ether}(
            3,
            "LockUp",
            EtherLockup.LockType.Fees
        );
        assertEq(etherLockup.getLockupDetailsById(1).locked, true);

        skip(3 * 30 * 24 * 60 * 60 + 1);
        etherLockup.unlockEther(1);
        vm.expectRevert(EtherLockup.LockupIsntLocked.selector);
        etherLockup.extendLockup(1, 1);
        vm.stopPrank();
    }

    function testUnlockTimeHasNotReached() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        etherLockup.lockEther{value: 6 ether}(
            3,
            "LockUp No1",
            EtherLockup.LockType.Fees
        );

        vm.expectRevert(EtherLockup.UnlockTimeHasNotReached.selector);
        etherLockup.unlockEther(1);

        //skip by a month to test if it will go through
        skip(1 * 30 * 24 * 60 * 60 + 1);

        vm.expectRevert(EtherLockup.UnlockTimeHasNotReached.selector);
        etherLockup.withdraw();
        //skip by another month totest if it will go through
        skip(1 * 30 * 24 * 60 * 60 + 1);

        vm.expectRevert(EtherLockup.UnlockTimeHasNotReached.selector);
        etherLockup.emergencyWithdraw();

        vm.stopPrank();
    }

    function testAdditionalMonthsShouldBeMoreThanZero() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        etherLockup.lockEther{value: 6 ether}(
            3,
            "My First LockUp",
            EtherLockup.LockType.Fees
        );

        vm.expectRevert(
            EtherLockup.AdditionalMonthsShouldBeMoreThanZero.selector
        );
        etherLockup.extendLockup(0, 1);
        vm.stopPrank();
    }

    function testNoLockupHasBeenDone() public {
        vm.startPrank(alice);
        assertEq(address(etherLockup).balance, 0);

        vm.expectRevert(EtherLockup.NoLockupHasBeenDone.selector);
        etherLockup.emergencyWithdraw();

        vm.stopPrank();
    }
}
