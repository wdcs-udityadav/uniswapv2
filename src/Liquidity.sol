//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

// import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
// import "@uniswap/v2-periphery/contracts/libraries/UniswapV2LiquidityMathLibrary.sol";
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract Liquidity {
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function addLiquidity(address _token0, address _token1, uint256 _amount0, uint256 _amount1, address _to)
        external
        returns (uint256 amount0, uint256 amount1, uint256 lp_tokens)
    {
        require(_token0 != _token1, "token0 == token1");
        TransferHelper.safeTransferFrom(_token0, msg.sender, address(this), _amount0);
        TransferHelper.safeTransferFrom(_token1, msg.sender, address(this), _amount1);
        TransferHelper.safeApprove(_token0, address(router), _amount0);
        TransferHelper.safeApprove(_token1, address(router), _amount1);

        (amount0, amount1, lp_tokens) =
            router.addLiquidity(_token0, _token1, _amount0, _amount1, 1, 1, _to, block.timestamp);
    }

    // function removeLiquidity(uint256 _lp_tokens, address _token0, address _token1)
    //     external
    //     returns (uint256 amount0, uint256 amount1)
    // {}
}
