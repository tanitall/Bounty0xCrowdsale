pragma solidity ^0.4.11;

import "minimetoken/contracts/MiniMeToken.sol";

contract Bounty0xToken is MiniMeToken {
    function Bounty0xToken(address _controller, address _tokenFactory)
        MiniMeToken(
            _tokenFactory,
            0x0,                        // no parent token
            0,                          // no snapshot block number from parent
            "Bounty0x Token",           // Token name
            18   ,                      // Decimals
            "BNTY",                     // Symbol
            false                       // Enable transfers
        )
        public
    {
        changeController(_controller);
    }
}