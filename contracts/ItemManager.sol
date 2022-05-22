//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Item.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract ItemManager is Ownable {
    enum SupplyChainSteps {
        Created,
        Paid,
        Delivered
    }

    struct S_Item {
        Item item;
        string identifier;
        uint256 itemPrice;
        ItemManager.SupplyChainSteps step;
    }

    mapping(uint256 => S_Item) public items;
    uint256 index;

    event SupplyChainStep(
        uint256 _itemIndex,
        uint256 _step,
        address _itemAddress
    );

    function createItem(string memory _identifier, uint256 _itemPrice)
        public
        onlyOwner
    {
        Item item = new Item(this, _itemPrice, index);
        items[index].item = item;
        items[index].identifier = _identifier;
        items[index].itemPrice = _itemPrice;
        items[index].step = SupplyChainSteps.Created;

        emit SupplyChainStep(index, uint256(items[index].step), address(item));
        index++;
    }

    function triggerPayment(uint256 _index) public payable {
        Item item = items[_index].item;
        require(
            address(item) == msg.sender,
            "Only items are allowed to update themselves"
        );
        require(item.itemPrice() == msg.value, "Not fully paid yet");
        require(items[_index].itemPrice <= msg.value, "Not fully paid!");
        require(
            items[_index].step == SupplyChainSteps.Created,
            "Item is further in the supply chain"
        );

        items[_index].step = SupplyChainSteps.Paid;
        emit SupplyChainStep(
            _index,
            uint256(items[_index].step),
            address(items[_index].item)
        );
    }

    function triggerDelivery(uint256 _index) public onlyOwner {
        require(
            items[_index].step == SupplyChainSteps.Paid,
            "Item is further in the supply chain"
        );
        items[_index].step = SupplyChainSteps.Delivered;
        emit SupplyChainStep(
            _index,
            uint256(items[_index].step),
            address(items[_index].item)
        );
    }
}
