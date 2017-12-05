pragma solidity ^0.4.18;

import './KnowsConstants.sol';
import './Bounty0xToken.sol';
import './KnowsTime.sol';

/**
 * @title Bounty0xReserveHolder
 * @dev Bounty0xReserveHolder is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract Bounty0xReserveHolder is KnowsConstants, KnowsTime {
    // Bounty0xToken address
    Bounty0xToken public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    function Bounty0xReserveHolder(Bounty0xToken _token, address _beneficiary) public {
        require(_token != address(0));
        require(_beneficiary != address(0));

        token = _token;
        beneficiary = _beneficiary;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        require(currentTime() >= UNFREEZE_DATE);

        uint amount = token.balanceOf(this);
        require(amount > 0);

        require(token.transfer(beneficiary, amount));
    }
}
