pragma solidity ^0.4.11;

import 'minimetoken/contracts/MiniMeToken.sol';

contract Bounty0xToken is MiniMeToken {
    function Bounty0xToken(address _tokenFactory)
        MiniMeToken(
            _tokenFactory,
            0x0,                        // no parent token
            0,                          // no snapshot block number from parent
            "Bounty0x Token",           // Token name
            18   ,                      // Decimals
            "BNTY",                     // Symbol
            false                       // Disable transfers
        )
        public
    {
    }

    // generate tokens for many addresses with a single transaction
    function generateTokensAll(address[] _owners, uint[] _amounts) onlyController {
      require(_owners.length == _amounts.length);

      for (uint i = 0; i < _owners.length; i++) {
        require(generateTokens(_owners[i], _amounts[i]));
      }
    }
}
