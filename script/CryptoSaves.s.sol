// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {CryptoSaves} from "../src/CryptoSaves.sol";

contract CryptoSavesScript is Script {
    function run() external {
        vm.startBroadcast();
        console.log("Deploying CryptoSaves deployer....");
        CryptoSaves cryptoSave = new CryptoSaves();
        console.log("CryptoSaves Contract Deployed To:", address(cryptoSave));
        vm.stopBroadcast();
    }
}
