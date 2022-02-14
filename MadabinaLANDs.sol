// ███    ███  █████  ██████   █████  ██████  ██ ███    ██  █████      ██████  ██████  ███    ███ 
// ████  ████ ██   ██ ██   ██ ██   ██ ██   ██ ██ ████   ██ ██   ██    ██      ██    ██ ████  ████ 
// ██ ████ ██ ███████ ██   ██ ███████ ██████  ██ ██ ██  ██ ███████    ██      ██    ██ ██ ████ ██ 
// ██  ██  ██ ██   ██ ██   ██ ██   ██ ██   ██ ██ ██  ██ ██ ██   ██    ██      ██    ██ ██  ██  ██ 
// ██      ██ ██   ██ ██████  ██   ██ ██████  ██ ██   ████ ██   ██ ██  ██████  ██████  ██      ██

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact contact@madabina.com
contract MadabinaLANDs is ERC721, ERC721Enumerable, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public minRate = 0.01 ether;
    uint public MAX_SUPPLY = 4000; // MAX tokens = 4000

    constructor() ERC721("Madabina LANDs", "MDBNL") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://madabina.com/nft_meta/2/"; // Madabina LANDs ID = 2 
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _tokenIdCounter.increment();
        //uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
    }

    function mint(uint256 tokenId) public payable {
        require(MAX_SUPPLY > totalSupply(), "Can't mint more");
        require(msg.value >= minRate, "No enough ETH sent.");
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Withdraw
    function withdraw() public onlyOwner{
        require(address(this).balance>0, "Balance is 0.");
        payable(owner()).transfer(address(this).balance);
    }
}