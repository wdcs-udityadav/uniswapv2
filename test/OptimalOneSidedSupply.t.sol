// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {OptimalOneSidedSupply} from "../src/OptimalOneSidedSupply.sol";

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OptimalOneSidedSupplyTest is Test {
    OptimalOneSidedSupply public oneSidedSupply;
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address user = vm.addr(1);
    address pair;

    function setUp() public {
        oneSidedSupply = new OptimalOneSidedSupply();
    }

    function testSwapAndAddLiquidity() external {
        deal(address(dai), user, 10000 * 1e18);

        vm.startPrank(user);
        assertEq(dai.balanceOf(user), 10000 * 1e18);
        assertEq(weth.balanceOf(user), 0);

        dai.approve(address(oneSidedSupply), 10000 * 1e18);

        (uint256 amount0, uint256 amount1, uint256 lp_tokens) =
            oneSidedSupply.swapAndAddLiquidity(address(dai), address(weth), 10000 * 1e18, user);

        assertEq(dai.balanceOf(user), 0);
        assertEq(weth.balanceOf(user), 0);
        pair = UniswapV2Library.pairFor(factory, address(dai), address(weth));
        assertEq(IERC20(pair).balanceOf(user), lp_tokens);
        vm.stopPrank();
    }
}
