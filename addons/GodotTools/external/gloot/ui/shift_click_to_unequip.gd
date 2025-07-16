extends Node

@export var root: Node

const CtrlInventoryItemRect = preload("res://addons/gloot/ui/ctrl_inventory_item_rect.gd")

func _ready() -> void:
	for slot: CtrlItemSlotEx in root.find_children("", "CtrlItemSlotEx"):
		for child in slot.find_children("", "Node", true, false):
			if child is CtrlInventoryItemRect:
				Signals.safe_connect(self, child.clicked, _on_event.bind(slot))
		
func _on_event(slot: CtrlItemSlotEx):
	if Input.is_action_pressed("Inventory Quick Transfer"):
		var source_inventory: Inventory = (slot.item_slot._wr_source_inventory as WeakRef).get_ref()
		if source_inventory.has_place_for(slot.item_slot.get_item()):
			slot.item_slot.clear()
