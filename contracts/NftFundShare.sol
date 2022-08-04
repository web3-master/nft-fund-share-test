// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NftFundShare {
    ERC721 public nft;

    uint public tokenCount;
    mapping (uint -> uint) tokenIds;
    mapping (uint -> uint) percentages;
    mapping (uint -> uint) funds;
    uint percentageSum;

    event TokenAdded(uint indexed tokenId, uint percentage);
    event FundReceived(address indexed from, uint amount);
    event FundWithdrawn(uint indexed tokenId, address indexed to, uint amount);

    constructor(ERC721 _nft) {
        nft = _nft;
    }

    function addToken(int tokenId, uint percentage) {
        uint id = tokenCount++;

        tokenIds[id] = tokenId;
        percentages[id] = percentage;
        funds[id] = 0;

        emit TokenAdded(tokenId, percentage);

        uint sum;
        for (uint i = 0; i < tokenCount; i++) {
            sum = sum + percentages[i];
        }
        percentageSum = sum;
    }

    function receiveFund() payable {
        require(msg.value > 0, "Invalid fund value!");
        require(tokenCount > 0, "No nfts yet!");

        for (uint i = 0; i < tokenCount; i++) {
            funds[i] = funds[i] + (msg.value * percentages[i]) / percentageSum;
        }
        
        emit FundReceived(msg.sender, msg.value);
    }

    function withdrawFund() public {
        require(tokenCount > 0, "No nfts yet!");

        for (uint i = 0; i < tokenCount; i++) {
            uint fundToWithdraw = funds[i];
            if (fundToWithdraw > 0) {
                funds[i] = 0;
                payable(nft.ownerOf(tokenIds[i])).transfer(fundToWithdraw);
                emit FundWithdrawn(tokenIds[i], nft.ownerOf(tokenIds[i]), fundToWithdraw);
            }
        }
    }
}
