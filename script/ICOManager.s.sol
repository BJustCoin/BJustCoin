// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ICOManager} from "../src/ICOManager.sol";

contract ICOManagerScript is Script {
    ICOManager public icoManager;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        icoManager = new ICOManager();

        vm.stopBroadcast();
    }
}
