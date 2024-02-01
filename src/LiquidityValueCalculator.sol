//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2LiquidityMathLibrary.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./interfaces/ILiquidityValueCalculator.sol";

import "forge-std/console.sol";

contract LiquidityValueCalculator is ILiquidityValueCalculator {
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    function _pairInfo(address tokenA, address tokenB)
        private
        view
        returns (uint256 totalSupply, uint256 reserve0, uint256 reserve1, bool feeOn, uint256 kLast)
    {
        address _pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);
        IUniswapV2Pair pair = IUniswapV2Pair(_pair);

        totalSupply = pair.totalSupply();
        (uint256 resA, uint256 resB,) = pair.getReserves();
        (reserve0, reserve1) = tokenA == pair.token0() ? (resA, resB) : (resB, resA);

        feeOn = IUniswapV2Factory(factory).feeTo() != address(0);
        kLast = feeOn ? pair.kLast() : 0;
    }

    function getLiquidityShareValue(uint256 liquidity, address tokenA, address tokenB)
        external
        override
        returns (uint256 amount0, uint256 amount1)
    {
        (uint256 totalSupply, uint256 reserve0, uint256 reserve1, bool feeOn, uint256 kLast) = _pairInfo(tokenA, tokenB);
        (amount0, amount1) = UniswapV2LiquidityMathLibrary.computeLiquidityValue(
            reserve0, reserve1, totalSupply, liquidity, feeOn, kLast
        );
    }
}
