//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@uniswap/lib/contracts/libraries/Babylonian.sol";

contract OptimalOneSidedSupply {
    address public factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function getSwapAmount(uint256 _reserve, uint256 _amount) private pure returns (uint256) {
        return (Babylonian.sqrt((3988009 * _reserve * _reserve) + (3988000 * _reserve * _amount)) - (1997 * _reserve))
            / 1994;
    }

    function swap(address _token0, address _token1, uint256 _amount0) private returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _token0;
        path[1] = _token1;

        uint256[] memory amounts = router.swapExactTokensForTokens(_amount0, 0, path, address(this), block.timestamp);
        return amounts[1];
    }

    function addLiquidity(address _token0, address _token1, uint256 _amount0, uint256 _amount1, address _to)
        private
        returns (uint256 amountOut0, uint256 amountOut1, uint256 lp_tokens)
    {
        (amountOut0, amountOut1, lp_tokens) =
            router.addLiquidity(_token0, _token1, _amount0, _amount1, 1, 1, _to, block.timestamp);
    }

    function swapAndAddLiquidity(address _token0, address _token1, uint256 _amount0, address _to)
        external
        returns (uint256 amountOut0, uint256 amountOut1, uint256 lp_tokens)
    {
        require(_token0 != _token1, "token0 == token1");

        (address token0, address token1) = UniswapV2Library.sortTokens(_token0, _token1);
        (uint256 _res0, uint256 _res1) = UniswapV2Library.getReserves(factory, token0, token1);
        uint256 reserve0 = token0 == _token0 ? _res0 : _res1;

        uint256 swapAmount = getSwapAmount(reserve0, _amount0);

        TransferHelper.safeTransferFrom(_token0, msg.sender, address(this), _amount0);
        TransferHelper.safeApprove(_token0, address(router), _amount0);

        uint256 amountOut = swap(_token0, _token1, swapAmount);
        TransferHelper.safeApprove(token1, address(router), amountOut);
        (amountOut0, amountOut1, lp_tokens) = addLiquidity(_token0, _token1, _amount0 - amountOut, amountOut, _to);
    }
}
