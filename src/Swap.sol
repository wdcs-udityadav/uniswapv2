//SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2LiquidityMathLibrary.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract Swap {
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Router02 public router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    function swapTokensToEth(uint256 amount, address to) external returns (uint256) {
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amount);
        TransferHelper.safeApprove(DAI, address(router), amount);

        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = WETH;

        uint256[] memory amounts = router.swapExactTokensForTokens(amount, 0, path, to, block.timestamp);
        return amounts[1];
    }
}
