// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable, VRFConsumerBase {
    // Chainlink VRF variables
    bytes32 internal keyHash;
    uint256 internal fee;

    // NFT traits
    uint256[] public energyTraits;  // Example traits, you can add more
    uint256[] public speedTraits;   // Example traits, you can add more

    // Mapping to track minted tokens
    mapping(uint256 => bool) public isMinted;

    constructor(
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    )
        ERC721("MyNFT", "NFT")
        VRFConsumerBase(_vrfCoordinator, _link)
    {
        keyHash = _keyHash;
        fee = _fee;
    }

    function mint() external {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK tokens");
        require(totalSupply() < 100, "Token limit reached");

        // Request a random number from Chainlink VRF
        requestRandomness(keyHash, fee);

        // Mint the token to the caller
        uint256 tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);

        // Mark the token as minted
        isMinted[tokenId] = true;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 trait1 = randomness % 101;  // Example random trait generation
        uint256 trait2 = (randomness >> 128) % 101;  // Example random trait generation

        // Store the generated traits
        energyTraits.push(trait1);
        speedTraits.push(trait2);
    }

    // Function to retrieve the traits of a specific token
    function getTokenTraits(uint256 tokenId) external view returns (uint256, uint256) {
        require(_exists(tokenId), "Token does not exist");
        return (energyTraits[tokenId - 1], speedTraits[tokenId - 1]);
    }
}
