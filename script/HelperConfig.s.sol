// SPDX-License-Identifier: MIT

// 1. deploy mocks when on local anvil
// 2. keey track of contract address acros different chains
// Seploia ETH/USD
// Mainnet ETH/USD

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetwrokConfig {
        uint256 entrancefee;
        uint256 iterval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subID;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant MAINENT_CHAIN_ID = 1;
    NetwrokConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            // local anvil
            activeNetworkConfig = getSepoliaEthConfig();
        }
        // else if (block.chainid == MAINENT_CHAIN_ID) {
        //     // mainnet
        //     activeNetworkConfig = getMainnetEthConfig();
        // }
        else {
            // anvil
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetwrokConfig memory) {
        // ETH price feed address
        NetwrokConfig memory sepoliaConfig = NetwrokConfig({
            entrancefee: 0.01 ether,
            iterval: 30 seconds,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subID: 4322, // update with own subID
            callbackGasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
        return sepoliaConfig;
    }

    // function getMainnetEthConfig() public pure returns (NetwrokConfig memory) {
    //     // ETH price feed address
    //     NetwrokConfig memory sepoliaConfig = NetwrokConfig({
    //         priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    //     });
    //     return sepoliaConfig;
    // }

    function getOrCreateAnvilEthConfig() public returns (NetwrokConfig memory) {
        // check to see if already deployed
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 basPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            basPriceLink
        );
        LinkToken link = new LinkToken();

        vm.stopBroadcast();

        return
            NetwrokConfig({
                entrancefee: 0.01 ether,
                iterval: 30 seconds,
                vrfCoordinator: address(vrfCoordinatorMock),
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subID: 0, // our script will add this
                callbackGasLimit: 500000,
                link: address(link),
                deployerKey: vm.envUint("LOC_PRIVATE_KEY")
            });
    }
}
