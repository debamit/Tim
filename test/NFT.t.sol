// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/NFT.sol";

contract NFTTest is Test {
    using stdStorage for StdStorage;

    NFT private nft;

    function setUp() public {
        // Deploy NFT contract
        nft = new NFT("NFT_tutorial", "TUT", "baseUri");
    }

    function testFailNoMintPricePaid() public {
        nft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMaxSupplyReached() public {
        uint256 slot = stdstore
            .target(address(nft))
            .sig("currentTokenId()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(nft), loc, mockedCurrentTokenId);
        nft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMintToZeroAddress() public {
        nft.mintTo{value: 0.08 ether}(address(0));
    }

    function testFailNonExistentTokenURI() public {
        uint256 slot = stdstore
            .target(address(nft))
            .sig("ownerOf(uint256)")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedOwnerOf = bytes32(abi.encode(address(0)));
        vm.store(address(nft), loc, mockedOwnerOf);
        nft.tokenURI(1);
    }

    function testBalanceIncremented() public {
        nft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotBalance = stdstore
            .target(address(nft))
            .sig(nft.balanceOf.selector)
            .with_key(address(1))
            .find();

        uint256 balanceFirstMint = uint256(
            vm.load(address(nft), bytes32(slotBalance))
        );
        assertEq(balanceFirstMint, 1);

        nft.mintTo{value: 0.08 ether}(address(1));
        uint256 balanceSecondMint = uint256(
            vm.load(address(nft), bytes32(slotBalance))
        );
        assertEq(balanceSecondMint, 2);
    }

    // function testBalanceIncremented() public {
    //     uint256 slot = stdstore
    //         .target(address(nft))
    //         .sig("balanceOf(address)")
    //         .find();
    //     bytes32 loc = bytes32(slot);
    //     bytes32 mockedBalanceOf = bytes32(abi.encode(0));
    //     vm.store(address(nft), loc, mockedBalanceOf);
    //     nft.mintTo{value: 0.08 ether}(address(1));
    //     uint256 balance = nft.balanceOf(address(1));
    //     assertEq(balance, 1);
    // }

}