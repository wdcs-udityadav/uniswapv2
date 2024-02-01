// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import {LiquidityValueCalculator} from "../src/LiquidityValueCalculator.sol";

contract LiquidityValueCalculatorTest is Test {
    LiquidityValueCalculator public lcv;

    function setUp() public {
        lcv = new LiquidityValueCalculator();
    }

    function testGetLiquidityShareValue() public {
        (uint256 amount0, uint256 amount1) = lcv.getLiquidityShareValue(
            10 * 1e18, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );

        console.log(amount0, amount1);
    }
}
