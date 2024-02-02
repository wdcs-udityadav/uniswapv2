//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract Liquidity {
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function getOptimalLiquidity(address _token0, address _token1, uint256 _amount0, uint256 _amount1)
        public
        view
        returns (address token0, address token1, uint256 amount0, uint256 amount1)
    {
        require(_token0 != _token1, "token0 == token1");
        (token0, token1) = UniswapV2Library.sortTokens(_token0, _token1);
        (uint256 res0, uint256 res1) = UniswapV2Library.getReserves(factory, token0, token1);

        (amount0, amount1) = token0 == _token0 ? (_amount0, _amount1) : (_amount1, _amount0);

        if (res0 != 0 || res1 != 0) {
            uint256 amount1Optimal = UniswapV2Library.quote(amount1, res0, res1);
            if (amount1Optimal <= amount1) {
                (amount0, amount1) = (amount0, amount1Optimal);
            } else {
                uint256 amount0Optimal = UniswapV2Library.quote(amount1, res0, res1);
                assert(amount0Optimal <= amount0);
                (amount0, amount1) = (amount0Optimal, amount1);
            }
        }
    }

    function addLiquidity(address _token0, address _token1, uint256 _amount0, uint256 _amount1, address _to)
        external
        returns (uint256 amountOut0, uint256 amountOut1, uint256 lp_tokens)
    {
        (address token0, address token1, uint256 amount0, uint256 amount1) =
            getOptimalLiquidity(_token0, _token1, _amount0, _amount1);
        TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amount0);
        TransferHelper.safeTransferFrom(token1, msg.sender, address(this), amount1);
        TransferHelper.safeApprove(token0, address(router), amount0);
        TransferHelper.safeApprove(token1, address(router), amount1);

        (amountOut0, amountOut1, lp_tokens) =
            router.addLiquidity(token0, token1, amount0, amount1, 1, 1, _to, block.timestamp);
    }

    function removeLiquidity(uint256 _lp_tokens, address _token0, address _token1, address _to)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        require(_token0 != _token1, "token0 == token1");
        (address token0, address token1) = UniswapV2Library.sortTokens(_token0, _token1);
        address pair = UniswapV2Library.pairFor(factory, token0, token1);

        TransferHelper.safeTransferFrom(pair, msg.sender, address(this), _lp_tokens);
        TransferHelper.safeApprove(pair, address(router), _lp_tokens);

        (amount0, amount1) = router.removeLiquidity(token0, token1, _lp_tokens, 1, 1, _to, block.timestamp);
    }
}
