// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {Liquidity} from "../src/Liquidity.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LiquidityTest is Test {
    Liquidity public liquidity;
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        liquidity = new Liquidity();
    }

    function testAddLiquidity() public {
        address user = vm.addr(1);
        deal(address(dai), user, 5000 * 1e18);
        deal(address(weth), user, 5000 * 1e18);

        vm.startPrank(user);

        assertEq(dai.balanceOf(user), 5000 * 1e18);
        assertEq(weth.balanceOf(user), 5000 * 1e18);

        dai.approve(address(liquidity), 5000 * 1e18);
        weth.approve(address(liquidity), 5000 * 1e18);

        (uint256 amount0, uint256 amount1, uint256 lp_tokens) =
            liquidity.addLiquidity(address(dai), address(weth), 5000 * 1e18, 5000 * 1e18, user);
        console.log("amount0: ", amount0);
        console.log("amount1: ", amount1);

        console.log(dai.balanceOf(user));
        console.log(weth.balanceOf(user));
        console.log("lp_tokens: ", lp_tokens/1e18);

        vm.stopPrank();
    }
}
