pragma solidity ^0.4.11;

/*
    This contract adds modifier to VestedToken contract in order to restrict creating
    vesting on to contribution contract for security purposes.
*/

contract GrantsControlled {
    modifier onlyGrantsController {
        assert(msg.sender == grantsController);
        _;
    }

    address public grantsController;

    function GrantsControlled() { grantsController = msg.sender;}

    function changeGrantsController(address _newController) onlyGrantsController {
        grantsController = _newController;
    }
}
