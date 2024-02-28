// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CryptoSaves.sol";
import "forge-std/console.sol";

contract CryptoSavesCheatsTest is Test {
    CryptoSaves public cryptoSaves;
    address alice = vm.addr(0x2);

    function setUp() public {
        vm.startPrank(alice);
        cryptoSaves = new CryptoSaves(8); //using 8 months as my emergency time
        vm.stopPrank();
    }

    function testLockEther() public {
        vm.startPrank(alice);

        /// crediting aka dealing 200 ethers to alice account
        vm.deal(alice, 200 ether);

        // first lockup
        cryptoSaves.lockEther{value: 5 ether}(3, "LockUpOne", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).amount, 5e18);

        // second lockup
        cryptoSaves.lockEther{value: 50 ether}(6, "LockUpTwo", "Family");
        assertEq(cryptoSaves.getLockupDetailsById(2).amount, 50e18);

        vm.stopPrank();
    }

    function testUnlockEther() public {
        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        cryptoSaves.lockEther{value: 5 ether}(3, "My First LockUp", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).amount, 5e18);

        // Locking up 50 ether for 6*30 days
        cryptoSaves.lockEther{value: 50 ether}(6, "My Second LockUp", "Travel");
        assertEq(cryptoSaves.getLockupDetailsById(2).amount, 50e18);

        // skips forward into the future to  3*30 days from now to be able to unlock
        skip(7776001);

        // unlocks
        cryptoSaves.unlockEther(1);
        assertEq(cryptoSaves.getLockupDetailsById(1).locked, false);
        assertEq(address(alice).balance, 10e18);

        // skips more forward into the future to  3*30 days
        // so a total of 6*30 days from now to be able to unlock
        skip(7776001);

        //second unlock
        cryptoSaves.unlockEther(2);
        assertEq(cryptoSaves.getLockupDetailsById(2).locked, false);
        assertEq(address(alice).balance, 60e18);

        vm.stopPrank();
    }

    function testExtendLockTime() public {
        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        // Locking up 5 ether for 3*30 days
        cryptoSaves.lockEther{value: 5 ether}(3, "LockUpOne", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).amount, 5e18);

        cryptoSaves.extendLockTime(3, 1);
        assertGt(cryptoSaves.getLockupDetailsById(1).releaseTime, 7776001);
    }

    function testGetAllLockUps() public {
        vm.startPrank(alice);
        vm.deal(alice, 60 ether);

        // third lockup
        cryptoSaves.lockEther{value: 5 ether}(3, "LockUpOne", "Fees");
        // second lockup
        cryptoSaves.lockEther{value: 7 ether}(6, "LockUpTwo", "Fees");
        //third lockup
        cryptoSaves.lockEther{value: 21 ether}(6, "LockUpThree", "Pets");
        //fourth lockup
        cryptoSaves.lockEther{value: 11 ether}(6, "LockUpFour", "Festivals");

        // now check for all lockupdetails

        //first lockup
        assertEq(cryptoSaves.getAllLockUps()[1].amount, 5e18);
        assertEq(cryptoSaves.getAllLockUps()[1].locked, true);

        //second lockup
        assertEq(cryptoSaves.getAllLockUps()[2].amount, 7e18);
        assertEq(cryptoSaves.getAllLockUps()[2].locked, true);
        //third lockup
        assertEq(cryptoSaves.getAllLockUps()[4].amount, 11e18);
        assertEq(cryptoSaves.getAllLockUps()[4].locked, true);

        vm.stopPrank();
    }

    function testGetLockupDetailsById() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        // Locking up 5 ether for 3*30 days
        cryptoSaves.lockEther{value: 10 ether}(3, "LockUpOne", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).amount, 10e18);
        assertEq(cryptoSaves.getLockupDetailsById(1).locked, true);
        assertEq(cryptoSaves.getLockupDetailsById(1).lockId, 1);

        assertGt(
            cryptoSaves.getLockupDetailsById(1).releaseTime,
            3 * 30 * 24 * 60 * 60
        );
        // the months * days*hrs*min*sec
    }

    function testWithdrawAllEther() public {
        vm.deal(address(cryptoSaves), 4 ether);

        vm.startPrank(alice);

        vm.deal(alice, 60 ether);

        cryptoSaves.lockEther{value: 5 ether}(3, "LockUpOne", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).locked, true);

        skip(7776001);

        //withdraws all the money in the contract
        cryptoSaves.withdrawAllEther();
        assertEq(address(alice).balance, 64e18);

        vm.stopPrank();
    }

    function testEmergencyWithdraw() public {
        vm.deal(address(cryptoSaves), 48 ether);
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        cryptoSaves.lockEther{value: 6 ether}(3, "My First LockUp", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).amount, 6e18);
        assertEq(
            cryptoSaves.getLockupDetailsById(1).amount + address(alice).balance,
            10e18
        );
        // the emergency withdraw time is after 8*30 daysso to to skip intime after then

        skip(8 * 30 * 24 * 60 * 60 + 1);

        //withdraws all the money in the contract for emergencies
        cryptoSaves.emergencyWithdraw();

        assertEq(address(alice).balance, 58e18);

        vm.stopPrank();
    }

    function testCannotLockZeroEther() public {
        vm.startPrank(alice);
        vm.expectRevert(CryptoSaves.CannotLockZeroEther.selector);
        cryptoSaves.lockEther{value: 0 ether}(3, "First Locking", "Pets");
        vm.stopPrank();
    }

    function testLockupIsntLocked() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        cryptoSaves.lockEther{value: 6 ether}(3, "LockUp", "Fees");
        assertEq(cryptoSaves.getLockupDetailsById(1).locked, true);

        skip(3 * 30 * 24 * 60 * 60 + 1);
        cryptoSaves.unlockEther(1);
        vm.expectRevert(CryptoSaves.LockupIsntLocked.selector);
        cryptoSaves.extendLockTime(1, 1);
        vm.stopPrank();
    }

    function testUnlockTimeHasNotReached() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        cryptoSaves.lockEther{value: 6 ether}(3, "LockUp No1", "Fees");

        vm.expectRevert(CryptoSaves.UnlockTimeHasNotReached.selector);
        cryptoSaves.unlockEther(1);

        //skip by a month to test if it will go through
        skip(1 * 30 * 24 * 60 * 60 + 1);

        vm.expectRevert(CryptoSaves.UnlockTimeHasNotReached.selector);
        cryptoSaves.withdrawAllEther();
        //skip by another month totest if it will go through
        skip(1 * 30 * 24 * 60 * 60 + 1);

        vm.expectRevert(CryptoSaves.UnlockTimeHasNotReached.selector);
        cryptoSaves.emergencyWithdraw();

        vm.stopPrank();
    }

    function testAdditionalMonthsShouldBeMoreThanZero() public {
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);

        cryptoSaves.lockEther{value: 6 ether}(3, "My First LockUp", "Fees");

        vm.expectRevert(
            CryptoSaves.AdditionalMonthsShouldBeMoreThanZero.selector
        );
        cryptoSaves.extendLockTime(0, 1);
        vm.stopPrank();
    }

    function testNoLockupHasBeenDone() public {
        vm.startPrank(alice);
        assertEq(address(cryptoSaves).balance, 0);

        vm.expectRevert(CryptoSaves.NoLockupHasBeenDone.selector);
        cryptoSaves.emergencyWithdraw();

        vm.stopPrank();
    }
}
