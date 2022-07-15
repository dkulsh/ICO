// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {

    uint256 public maxTotalSupply = 10000 * 10 ** 18;

    uint256 public tokensPerNFT = 10 * 10 ** 18;

    uint256 public constant tokenPrice = 0.001 ether;

    mapping(uint256 => bool) public tokenIdsClaimed;

    ICryptoDevs icryptoDevs;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {

        icryptoDevs = ICryptoDevs(_cryptoDevsContract);
    }

    function mint(uint256 amount) public payable {

        uint256 _etherCost = tokenPrice * amount;

        require(msg.value >= _etherCost, "Sent Ether are insufficient to mint the required tokens");

        uint256 _amountBigNum = amount * 10 ** 18;

        require(maxTotalSupply >= (totalSupply() + _amountBigNum), "Exceeded the max total supply available.");

        _mint(msg.sender, _amountBigNum);
    }

    function claim() public {

        address sender = msg.sender;

        uint256 balance = icryptoDevs.balanceOf(sender);

        require(balance > 0, "User must own some NFTs to get tokens");

        uint256 unclaimedNFTs = 0;

        for (uint8 i = 0; i < balance; i++) {

            uint256 tokenId = icryptoDevs.tokenOfOwnerByIndex(sender, i);

            if(! tokenIdsClaimed[tokenId]) {

                unclaimedNFTs += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        _mint(msg.sender, unclaimedNFTs * tokensPerNFT);   
    }

    function withdraw() public onlyOwner {

        address _owner = owner();

        uint256 _amount = address(this).balance;

        (bool _sent, ) = _owner.call{value: _amount } ("");

        require(_sent, "Failed to send the Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}