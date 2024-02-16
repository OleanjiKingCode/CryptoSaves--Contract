// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {EtherLockup} from "../src/EtherLockup.sol";

contract EtherLockupScript is Script {
    function run() external {
        vm.startBroadcast();
        console.log("Deploying EtherLockup deployer....");
        EtherLockup etherLockup = new EtherLockup();
        console.log("EtherLockup Contract Deployed To:", address(etherLockup));
        vm.stopBroadcast();
    }
}
