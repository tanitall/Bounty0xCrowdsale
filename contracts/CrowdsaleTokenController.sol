pragma solidity ^0.4.18;

import 'minimetoken/contracts/TokenController.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import './AddressWhitelist.sol';
import './Bounty0xToken.sol';

contract CrowdsaleTokenController is Ownable, AddressWhitelist, TokenController {
    Bounty0xToken public token;

    function CrowdsaleTokenController(Bounty0xToken _token) public {
        token = _token;
    }

    // the owner of the controller can change the controller to a new contract
    function changeController(address newController) public onlyOwner returns (bool) {
        token.changeController(newController);
    }

    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns (bool) {
        return false;
    }

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns (bool) {
        return isWhitelisted(_from);
    }

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public returns (bool) {
        return isWhitelisted(_owner);
    }
}
