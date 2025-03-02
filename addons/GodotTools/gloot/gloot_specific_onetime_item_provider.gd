class_name GlootSpecificOneTimeItemProvider
extends GlootItemProvider

var specific_item: InventoryItem

func _init(item: InventoryItem):
	specific_item = item

func use_item(count: int) -> int:
	queue_free()
	return use_specific_item(specific_item, count)

func use_specific_item(item: InventoryItem, count: int) -> int:
	specific_item = item
	return super.use_item(count)

func should_provide_item(item: InventoryItem) -> bool:
	return item == specific_item
