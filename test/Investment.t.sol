// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Investment.sol";
import "forge-std/console.sol";

contract InvestmentCheatsTest is Test {
    EtherLockup public etherLockup;
    address alice = vm.addr(0x2);
    address alices = vm.addr(0x3);
    address lice = vm.addr(0x4);

    function setUp() public {
        vm.startPrank(alice);
        etherLockup = new EtherLockup();
        vm.stopPrank();
    }

    function testlockEther() public {
        vm.startPrank(alice);
        vm.deal(alice, 200 ether);
        etherLockup.lockEther{value: 5 ether}(3);

        console.log(
            "This is the details of the first lock Up",
            etherLockup.getLockupDetails(1).amount,
            etherLockup.getLockupDetails(1).releaseTime
        );
        assertEq(etherLockup.getLockupDetails(1).amount, 5e18);
        etherLockup.lockEther{value: 50 ether}(6);
        assertEq(etherLockup.getLockupDetails(2).amount, 50e18);
        console.log(
            etherLockup.getLockupDetails(2).lockId,
            etherLockup.getLockupDetails(2).amount,
            etherLockup.getLockupDetails(2).releaseTime
        );
        vm.stopPrank();
    }

    function testunlockEther() public {
        vm.startPrank(alice);
        vm.deal(alice, 60 ether);
        etherLockup.lockEther{value: 5 ether}(3);

        console.log(
            "This is the details",
            etherLockup.getLockupDetails(1).lockId,
            etherLockup.getLockupDetails(1).amount
        );
        console.log(
            etherLockup.getLockupDetails(1).releaseTime,
            etherLockup.getLockupDetails(1).locked,
            address(alice).balance
        );

        etherLockup.lockEther{value: 50 ether}(6);
        console.log(
            etherLockup.getLockupDetails(2).lockId,
            etherLockup.getLockupDetails(2).releaseTime,
            etherLockup.getLockupDetails(2).locked,
            address(alice).balance
        );

        skip(7776001);
        etherLockup.unlockEther(1);
        skip(7776001);
        etherLockup.unlockEther(2);

        console.log(
            "This is the details",
            etherLockup.getLockupDetails(1).lockId,
            etherLockup.getLockupDetails(1).amount
        );
        console.log(
            etherLockup.getLockupDetails(1).releaseTime,
            etherLockup.getLockupDetails(1).locked,
            address(alice).balance
        );
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
