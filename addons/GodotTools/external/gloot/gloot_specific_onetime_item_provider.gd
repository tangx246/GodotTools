class_name GlootSpecificOneTimeItemProvider
extends GlootItemProvider

var specific_item: InventoryItem

func _init(root: Node, item: InventoryItem):
	self.root = root
	specific_item = item

func use_item(count: int) -> int:
	queue_free()
	if not is_instance_valid(specific_item):
		printerr("Invalid item")
		print_stack()
		return 0
	return use_specific_item(specific_item, count)

func use_specific_item(item: InventoryItem, count: int) -> int:
	specific_item = item
	return super.use_item(count)

func should_provide_item(item: InventoryItem) -> bool:
	return item == specific_item
