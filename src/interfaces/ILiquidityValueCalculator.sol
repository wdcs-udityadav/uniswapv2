//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

interface ILiquidityValueCalculator {
    function getLiquidityShareValue(uint256 liquidity, address token0, address token1)
        external
        returns (uint256 amount0, uint256 amount1);
}
