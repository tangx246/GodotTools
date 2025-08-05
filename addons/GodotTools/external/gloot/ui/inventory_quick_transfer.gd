class_name InventoryQuickTransfer
extends Node

@export var inventory_a_root: Node
@export var inventory_b_root: Node
@onready var inventory_a: CtrlInventoryGridEx = inventory_a_root.find_children("", "CtrlInventoryGridEx")[0]
@onready var inventory_b: CtrlInventoryGridEx = inventory_b_root.find_children("", "CtrlInventoryGridEx")[0]

func _ready() -> void:
	Signals.safe_connect(self, inventory_a.selection_changed, _on_item_clicked.bind(inventory_a, inventory_b))
	Signals.safe_connect(self, inventory_b.selection_changed, _on_item_clicked.bind(inventory_b, inventory_a))
	
func _on_item_clicked(from: CtrlInventoryGridEx, to: CtrlInventoryGridEx) -> void:
	if not from.is_visible_in_tree() or not to.is_visible_in_tree():
		return
	
	if Input.is_action_pressed("Inventory Quick Transfer"):
		var item: InventoryItem = from.get_selected_inventory_item()
		if item:
			quick_transfer(item, from.inventory, to.inventory)

static func quick_transfer(item: InventoryItem, from: Inventory, to: Inventory):
	if not from.transfer_automerge(item, to):
		print("Not enough space in inventory!")
