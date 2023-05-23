// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract RefiSureDAONft is ERC721 {
    string public constant TOKEN_URI =
        "ipfs://QmTdFT4rN95DhQNDstJkZLjicvDjCpYb8JwGKRE3RwkFoy";
    uint256 private s_tokenCounter;

    constructor() ERC721("RefiSureDAONft", "RSDNFT") {
        s_tokenCounter = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
