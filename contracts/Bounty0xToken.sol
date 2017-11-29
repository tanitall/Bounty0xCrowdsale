pragma solidity ^0.4.11;


import "minimetoken/contracts/MiniMeToken.sol";
import "./VestedToken.sol";

contract Bounty0xToken is MiniMeToken, VestedToken {
    function Bounty0xToken(address _controller, address _tokenFactory)
        MiniMeToken(
            _tokenFactory,
            0x0,                        // no parent token
            0,                          // no snapshot block number from parent
            "bounty0x Token",           // Token name
            18   ,                      // Decimals
            "BNTY",                     // Symbol
            false                       // Enable transfers
            )
    {
        changeController(_controller);
        changeGrantsController(_controller);
    }
}