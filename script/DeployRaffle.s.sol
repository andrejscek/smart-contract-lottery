// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        // before startBroadcast, will not send tx
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entrancefee,
            uint256 iterval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subID,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        if (subID == 0) {
            // create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subID = createSubscription.createSubscription(
                vrfCoordinator,
                deployerKey
            );

            // fund subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator,
                subID,
                link,
                deployerKey
            );
        }

        vm.startBroadcast(deployerKey);
        Raffle raffle = new Raffle(
            entrancefee,
            iterval,
            vrfCoordinator,
            gasLane,
            subID,
            callbackGasLimit
        );
        vm.stopBroadcast();

        // add consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinator,
            subID,
            deployerKey
        );
        return (raffle, helperConfig);
    }
}
