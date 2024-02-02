// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {Liquidity} from "../src/Liquidity.sol";

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract LiquidityTest is Test {
    Liquidity public liquidity;
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address user = vm.addr(1);
    address pair;

    function setUp() public {
        liquidity = new Liquidity();
    }

    function testAddLiquidity() public returns (uint256) {
        deal(address(dai), user, 5000 * 1e18);
        deal(address(weth), user, 5000 * 1e18);

        vm.startPrank(user);
        assertEq(dai.balanceOf(user), 5000 * 1e18);
        assertEq(weth.balanceOf(user), 5000 * 1e18);

        dai.approve(address(liquidity), 5000 * 1e18);
        weth.approve(address(liquidity), 5000 * 1e18);

        (uint256 amount0, uint256 amount1, uint256 lp_tokens) =
            liquidity.addLiquidity(address(dai), address(weth), 5000 * 1e18, 5000 * 1e18, user);

        assertEq(dai.balanceOf(user), 5000 * 1e18 - amount0);
        assertEq(weth.balanceOf(user), 5000 * 1e18 - amount1);
        pair = UniswapV2Library.pairFor(factory, address(dai), address(weth));
        assertEq(IERC20(pair).balanceOf(user), lp_tokens);
        vm.stopPrank();

        return lp_tokens;
    }

    function testRemoveLiquidity() public {
        uint256 lp_tokens = testAddLiquidity();

        vm.startPrank(user);
        assertEq(IERC20(pair).balanceOf(user), lp_tokens);
        uint256 dai_bal = dai.balanceOf(user);
        uint256 weth_bal = weth.balanceOf(user);

        IERC20(pair).approve(address(liquidity), lp_tokens);
        (uint256 amount0, uint256 amount1) = liquidity.removeLiquidity(lp_tokens, address(dai), address(weth), user);

        assertEq(dai.balanceOf(user), dai_bal + amount0);
        assertEq(weth.balanceOf(user), weth_bal + amount1);
        assertEq(IERC20(pair).balanceOf(user), 0);
        vm.stopPrank();
    }
}
