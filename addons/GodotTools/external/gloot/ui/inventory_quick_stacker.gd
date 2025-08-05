class_name InventoryQuickStacker
extends Node

@export var root: Node

func _ready() -> void:
	var inventories: Array[Node] = root.find_children("", "CtrlInventoryGridEx", true, false)
	for inventory: CtrlInventoryGridEx in inventories:
		Signals.safe_connect(self, inventory.inventory_item_activated, merge_stacks)

static func merge_stacks(item: InventoryItem) -> void:
	var inventory = item.get_inventory()
	var stacks_constraint = inventory._constraint_manager._stacks_constraint
	for other_item: InventoryItem in stacks_constraint.get_mergable_items(item):
		inventory.join_autosplit(item, other_item)
