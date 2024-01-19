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
            "This is the details",
            etherLockup.getAllLockUps().length,
            etherLockup.getAllLockUps()[1].lockId
          
        );
        console.log(
            etherLockup.getLockupDetails(0).amount,
            etherLockup.getLockupDetails(0).releaseTime,
            etherLockup.getLockupDetails(1).amount,
            etherLockup.getLockupDetails(1).releaseTime
        );
        etherLockup.lockEther{value: 50 ether}(6);
        console.log(
            etherLockup.getLockupDetails(2).lockId,
            etherLockup.getLockupDetails(2).amount,
            etherLockup.getLockupDetails(2).releaseTime
        );
        vm.stopPrank();
    }
}
