// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Defining a Struct for the Stats
    struct Stats {
        uint levels;
        uint hp;
        uint strength;
        uint speed;
    }

    mapping(uint256 => Stats) tokenIdtoStats;

    constructor() ERC721("Chain Battles", "CBTLS"){
    }

    function generateCharacter(uint256 tokenId) public returns(string memory){

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',"Class: Warrior",'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",getLevels(tokenId),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "HP: ",getHp(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",getStrength(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",getSpeed(tokenId),'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdtoStats[tokenId].levels;
        return levels.toString();
    }

    function getHp(uint256 tokenId) public view returns (string memory) {
        uint256 hp = tokenIdtoStats[tokenId].hp;
        return hp.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdtoStats[tokenId].strength;
        return strength.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 speed = tokenIdtoStats[tokenId].speed;
        return speed.toString();
    }

    function getTokenURI(uint256 tokenId) public returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    // Defining a random number
    // Initializing the state variable
    uint randNonce = 0;
 
    // Defining a function to generate a random number
    function randMod(uint _modulus) internal returns(uint) {
        // Increase nonce
        randNonce++; 
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        
        // Generates random Stats
        tokenIdtoStats[newItemId].levels = 0;
        tokenIdtoStats[newItemId].hp = randMod(200);
        tokenIdtoStats[newItemId].strength = randMod(100);
        tokenIdtoStats[newItemId].speed = randMod(100);

        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing NFT");
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");

        // Increase Level
        uint256 currentLevel = tokenIdtoStats[tokenId].levels;
        tokenIdtoStats[tokenId].levels = currentLevel + 1;

        // Increase HP
        uint256 currentHp = tokenIdtoStats[tokenId].hp;
        tokenIdtoStats[tokenId].hp = currentHp + randMod(20);

        // Increase Strength
        uint256 currentStrength = tokenIdtoStats[tokenId].strength;
        tokenIdtoStats[tokenId].strength = currentStrength + randMod(20);

        // Increase Speed
        uint256 currentSpeed = tokenIdtoStats[tokenId].speed;
        tokenIdtoStats[tokenId].speed = currentSpeed + randMod(20);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}