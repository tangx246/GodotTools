class_name GlootItemIdProvider
extends GlootItemProvider

var item_prototype_id: String

func _init(root: Node, item_prototype_id: String):
	self.root = root
	self.item_prototype_id = item_prototype_id

func should_provide_item(item: InventoryItem) -> bool:
	return item.prototype_id == item_prototype_id
