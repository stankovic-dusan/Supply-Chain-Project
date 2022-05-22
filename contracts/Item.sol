//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ItemManager.sol";

contract Item {
    uint256 public itemPrice;
    uint256 public index;
    uint256 public itemPaid;

    ItemManager parentContract;

    constructor(
        ItemManager _parentContract,
        uint256 _itemPrice,
        uint256 _index
    ) {
        itemPrice = _itemPrice;
        index = _index;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(msg.value == itemPrice, "We don't support partial payments");
        require(itemPaid == 0, "Item is already paid!");
        itemPaid += msg.value;
        (bool success, ) = address(parentContract).call{value: msg.value}(
            abi.encodeWithSignature("triggerPayment(uint256)", index)
        );
        require(success, "Delivery did not work");
    }
}
