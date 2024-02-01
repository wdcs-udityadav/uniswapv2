// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {Swap} from "../src/Swap.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SwapTest is Test {
    Swap public swap;
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        swap = new Swap();
    }

    function testSwap() public {
        address user = vm.addr(1);
        deal(address(dai), user, 5000 * 1e18);

        vm.startPrank(user);

        assertEq(dai.balanceOf(user), 5000 * 1e18);
        assertEq(weth.balanceOf(user), 0);
        dai.approve(address(swap), 5000 * 1e18);
        uint256 wethOut = swap.swapTokensToEth(5000 * 1e18, user);
        assertEq(dai.balanceOf(user), 0);
        assertEq(weth.balanceOf(user), wethOut);

        vm.stopPrank();
    }
}
