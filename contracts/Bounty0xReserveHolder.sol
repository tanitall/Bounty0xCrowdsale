pragma solidity ^0.4.18;

import './KnowsConstants.sol';
import './Bounty0xToken.sol';
import './KnowsTime.sol';

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title Bounty0xReserveHolder
 * @dev Bounty0xReserveHolder is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract Bounty0xReserveHolder is KnowsTime {
    // Bounty0xToken address
    Bounty0xToken public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint public releaseTime;

    function TokenTimelock(Bounty0xToken _token, address _beneficiary, uint _releaseTime) public {
        require(_releaseTime > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() public {
        require(currentTime() >= releaseTime);

        uint amount = token.balanceOf(this);
        require(amount > 0);

        require(token.transfer(beneficiary, amount));
    }
}
